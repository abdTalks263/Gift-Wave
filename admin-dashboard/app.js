// Global variables
let currentAdmin = null;
let currentRider = null;
let pendingRiders = [];
let allRiders = [];
let verificationHistory = [];

// DOM elements
const loginScreen = document.getElementById('loginScreen');
const dashboardScreen = document.getElementById('dashboardScreen');
const loginForm = document.getElementById('loginForm');
const loginError = document.getElementById('loginError');
const logoutBtn = document.getElementById('logoutBtn');
const riderModal = document.getElementById('riderModal');
const reasonModal = document.getElementById('reasonModal');

// Initialize app
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupEventListeners();
});

function initializeApp() {
    // Check if user is already logged in
    auth.onAuthStateChanged(function(user) {
        if (user) {
            checkAdminStatus(user.uid);
        } else {
            showLoginScreen();
        }
    });
}

function setupEventListeners() {
    // Login form
    loginForm.addEventListener('submit', handleLogin);
    
    // Logout
    logoutBtn.addEventListener('click', handleLogout);
    
    // Tab navigation
    document.querySelectorAll('.nav-btn[data-tab]').forEach(btn => {
        btn.addEventListener('click', () => switchTab(btn.dataset.tab));
    });
    
    // Refresh buttons
    document.getElementById('refreshPending').addEventListener('click', () => loadPendingRiders());
    document.getElementById('refreshAll').addEventListener('click', () => loadAllRiders());
    document.getElementById('refreshHistory').addEventListener('click', () => loadVerificationHistory());
    
    // Search and filter
    document.getElementById('searchRiders').addEventListener('input', filterRiders);
    document.getElementById('statusFilter').addEventListener('change', filterRiders);
    
    // Modal actions
    document.getElementById('approveBtn').addEventListener('click', () => handleRiderAction('approve'));
    document.getElementById('rejectBtn').addEventListener('click', () => handleRiderAction('reject'));
    document.getElementById('banBtn').addEventListener('click', () => handleRiderAction('ban'));
    document.getElementById('confirmReason').addEventListener('click', confirmRiderAction);
}

// Authentication functions
async function handleLogin(e) {
    e.preventDefault();
    
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    
    // Predefined admin credentials
    const defaultEmail = "admin@giftwave.com";
    const defaultPassword = "admin123!@#";
    
    try {
        showLoading();
        if (email === defaultEmail && password === defaultPassword) {
            // Use the predefined credentials
            await auth.signInWithEmailAndPassword(defaultEmail, defaultPassword);
        } else {
            // Try with provided credentials
            await auth.signInWithEmailAndPassword(email, password);
        }
    } catch (error) {
        hideLoading();
        showError('Login failed: ' + error.message);
    }
}

async function checkAdminStatus(userId) {
    try {
        const adminDoc = await db.collection('admins').doc(userId).get();
        
        if (adminDoc.exists) {
            currentAdmin = {
                id: userId,  // Add the ID to the admin object
                ...adminDoc.data()
            };
            showDashboard();
            loadInitialData();
        } else {
            await auth.signOut();
            showError('Access denied. You are not authorized as an admin.');
        }
    } catch (error) {
        console.error('Error checking admin status:', error);
        showError('Error checking admin status');
    }
}

async function handleLogout() {
    try {
        await auth.signOut();
        currentAdmin = null;
        showLoginScreen();
    } catch (error) {
        console.error('Error signing out:', error);
    }
}

// UI functions
function showLoginScreen() {
    loginScreen.classList.remove('hidden');
    dashboardScreen.classList.add('hidden');
    loginError.textContent = '';
}

function showDashboard() {
    loginScreen.classList.add('hidden');
    dashboardScreen.classList.remove('hidden');
    hideLoading();
}

function showError(message) {
    loginError.textContent = message;
    hideLoading();
}

function showLoading() {
    // Add loading indicator
    const btn = document.querySelector('.login-btn');
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Signing In...';
    btn.disabled = true;
}

function hideLoading() {
    const btn = document.querySelector('.login-btn');
    btn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Sign In';
    btn.disabled = false;
}

function switchTab(tabName) {
    // Update active tab button
    document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
    
    // Update active tab content
    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
    document.getElementById(tabName + 'Tab').classList.add('active');
    
    // Load data for the tab
    switch(tabName) {
        case 'pending':
            loadPendingRiders();
            break;
        case 'all':
            loadAllRiders();
            break;
        case 'history':
            loadVerificationHistory();
            break;
        case 'profile':
            loadAdminProfile();
            break;
    }
}

// Data loading functions
async function loadInitialData() {
    await Promise.all([
        loadPendingRiders(),
        loadVerificationHistory(),
        loadAdminProfile()
    ]);
}

async function loadPendingRiders() {
    try {
        const snapshot = await db.collection('users')
            .where('userType', '==', 'rider')
            .where('riderStatus', '==', 'pending')
            .get();
        
        pendingRiders = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        
        displayPendingRiders();
        updatePendingCount();
    } catch (error) {
        console.error('Error loading pending riders:', error);
        showNotification('Error loading pending riders', 'error');
    }
}

async function loadAllRiders() {
    try {
        const snapshot = await db.collection('users')
            .where('userType', '==', 'rider')
            .get();
        
        allRiders = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        
        displayAllRiders();
    } catch (error) {
        console.error('Error loading all riders:', error);
        showNotification('Error loading riders', 'error');
    }
}

async function loadVerificationHistory() {
    try {
        const snapshot = await db.collection('rider_verification_actions')
            .orderBy('timestamp', 'desc')
            .limit(50)
            .get();
        
        verificationHistory = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        
        displayVerificationHistory();
    } catch (error) {
        console.error('Error loading verification history:', error);
        showNotification('Error loading history', 'error');
    }
}

async function loadAdminProfile() {
    if (!currentAdmin) return;
    
    const profileContainer = document.getElementById('adminProfile');
    profileContainer.innerHTML = `
        <div class="profile-item">
            <span class="profile-label">Name:</span>
            <span class="profile-value">${currentAdmin.fullName}</span>
        </div>
        <div class="profile-item">
            <span class="profile-label">Email:</span>
            <span class="profile-value">${currentAdmin.email}</span>
        </div>
        <div class="profile-item">
            <span class="profile-label">Role:</span>
            <span class="profile-value">${currentAdmin.role}</span>
        </div>
        <div class="profile-item">
            <span class="profile-label">Status:</span>
            <span class="profile-value">${currentAdmin.isActive ? 'Active' : 'Inactive'}</span>
        </div>
    `;
}

// Display functions
function displayPendingRiders() {
    const container = document.getElementById('pendingRiders');
    
    if (pendingRiders.length === 0) {
        container.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 2rem; color: #666;">
                <i class="fas fa-users" style="font-size: 3rem; margin-bottom: 1rem;"></i>
                <h3>No Pending Riders</h3>
                <p>All rider applications have been processed.</p>
            </div>
        `;
        return;
    }
    
    container.innerHTML = pendingRiders.map(rider => createRiderCard(rider)).join('');
}

function displayAllRiders() {
    const container = document.getElementById('allRiders');
    
    if (allRiders.length === 0) {
        container.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 2rem; color: #666;">
                <i class="fas fa-users" style="font-size: 3rem; margin-bottom: 1rem;"></i>
                <h3>No Riders Found</h3>
                <p>No riders have registered yet.</p>
            </div>
        `;
        return;
    }
    
    container.innerHTML = allRiders.map(rider => createRiderCard(rider)).join('');
}

function displayVerificationHistory() {
    const container = document.getElementById('verificationHistory');
    
    if (verificationHistory.length === 0) {
        container.innerHTML = `
            <div style="text-align: center; padding: 2rem; color: #666;">
                <i class="fas fa-history" style="font-size: 3rem; margin-bottom: 1rem;"></i>
                <h3>No History</h3>
                <p>No verification actions have been performed yet.</p>
            </div>
        `;
        return;
    }
    
    container.innerHTML = verificationHistory.map(action => `
        <div class="history-item">
            <div class="history-info">
                <h4>${action.riderName}</h4>
                <p>${action.action} - ${action.reason || 'No reason provided'}</p>
            </div>
            <div class="history-meta">
                <div class="history-date">${formatDate(action.timestamp)}</div>
                <div class="status-badge status-${action.action}">${action.action}</div>
            </div>
        </div>
    `).join('');
}

function createRiderCard(rider) {
    const initials = rider.fullName.split(' ').map(n => n[0]).join('').toUpperCase();
    const statusClass = `status-${rider.riderStatus || 'pending'}`;
    const hasProfileImage = rider.profileImageURL && rider.profileImageURL.trim() !== '';
    
    return `
        <div class="rider-card" onclick="openRiderModal('${rider.id}')">
            <div class="rider-header">
                ${hasProfileImage ? 
                    `<div class="rider-avatar profile-image" style="background-image: url('${rider.profileImageURL}')"></div>` :
                    `<div class="rider-avatar">${initials}</div>`
                }
                <div class="rider-info">
                    <h3>${rider.fullName}</h3>
                    <p>${rider.email}</p>
                </div>
            </div>
            <div class="rider-details">
                <div class="detail-item">
                    <span class="detail-label">Phone</span>
                    <span class="detail-value">${rider.phoneNumber || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">City</span>
                    <span class="detail-value">${rider.city || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">CNIC</span>
                    <span class="detail-value">${rider.cnic || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Status</span>
                    <span class="status-badge ${statusClass}">${rider.riderStatus || 'pending'}</span>
                </div>
            </div>
        </div>
    `;
}

// Modal functions
function openRiderModal(riderId) {
    const rider = [...pendingRiders, ...allRiders].find(r => r.id === riderId);
    if (!rider) return;
    
    currentRider = rider;
    const hasProfileImage = rider.profileImageURL && rider.profileImageURL.trim() !== '';
    
    const detailsContainer = document.getElementById('riderDetails');
    detailsContainer.innerHTML = `
        <div class="rider-header">
            ${hasProfileImage ? 
                `<div class="rider-avatar profile-image" style="background-image: url('${rider.profileImageURL}')">
                    <a href="${rider.profileImageURL}" target="_blank" class="view-full-image" title="View full image">
                        <i class="fas fa-expand"></i>
                    </a>
                </div>` :
                `<div class="rider-avatar">${rider.fullName.split(' ').map(n => n[0]).join('').toUpperCase()}</div>`
            }
            <div class="rider-info">
                <h3>${rider.fullName}</h3>
                <p>${rider.email}</p>
            </div>
        </div>
        <div class="rider-details">
            <div class="detail-item">
                <span class="detail-label">Phone Number</span>
                <span class="detail-value">${rider.phoneNumber || 'N/A'}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">City</span>
                <span class="detail-value">${rider.city || 'N/A'}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">CNIC</span>
                <span class="detail-value">${rider.cnic || 'N/A'}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Registration Date</span>
                <span class="detail-value">${formatDate(rider.createdAt)}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Current Status</span>
                <span class="status-badge status-${rider.riderStatus || 'pending'}">${rider.riderStatus || 'pending'}</span>
            </div>
            ${rider.statusReason ? `
            <div class="detail-item" style="grid-column: 1 / -1;">
                <span class="detail-label">Status Reason</span>
                <span class="detail-value">${rider.statusReason}</span>
            </div>
            ` : ''}
        </div>
    `;
    
    riderModal.classList.remove('hidden');
}

function closeRiderModal() {
    riderModal.classList.add('hidden');
    currentRider = null;
}

function closeReasonModal() {
    reasonModal.classList.add('hidden');
    document.getElementById('rejectionReason').value = '';
}

// Action functions
function handleRiderAction(action) {
    if (!currentRider) return;
    
    if (action === 'reject' || action === 'ban') {
        reasonModal.classList.remove('hidden');
        document.getElementById('confirmReason').onclick = () => confirmRiderAction(action);
    } else {
        confirmRiderAction(action);
    }
}

async function confirmRiderAction(action = 'approve') {
    if (!currentRider) {
        showNotification('No rider selected', 'error');
        return;
    }
    
    if (!currentAdmin || !currentAdmin.id) {
        showNotification('Admin session error. Please log in again.', 'error');
        return;
    }
    
    const reason = document.getElementById('rejectionReason').value;
    if ((action === 'reject' || action === 'ban') && !reason.trim()) {
        showNotification('Please provide a reason for ' + action, 'error');
        return;
    }
    
    try {
        // Show loading state
        const confirmBtn = document.getElementById('confirmReason');
        if (confirmBtn) {
            confirmBtn.disabled = true;
            confirmBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
        }
        
        // Update rider status
        await db.collection('users').doc(currentRider.id).update({
            riderStatus: action === 'approve' ? 'approved' : action,
            statusReason: reason || null,
            updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
            updatedBy: currentAdmin.id
        });
        
        // Log verification action
        await db.collection('rider_verification_actions').add({
            riderId: currentRider.id,
            riderName: currentRider.fullName,
            action: action,
            reason: reason || null,
            adminId: currentAdmin.id,
            adminName: currentAdmin.fullName,
            timestamp: firebase.firestore.FieldValue.serverTimestamp()
        });
        
        // Refresh data
        await Promise.all([
            loadPendingRiders(),
            loadAllRiders(),
            loadVerificationHistory()
        ]);
        
        // Close modals
        closeRiderModal();
        closeReasonModal();
        
        showNotification(`Rider ${action}d successfully`, 'success');
    } catch (error) {
        console.error('Error updating rider:', error);
        showNotification(error.message || 'Error updating rider status', 'error');
    } finally {
        // Reset button state
        const confirmBtn = document.getElementById('confirmReason');
        if (confirmBtn) {
            confirmBtn.disabled = false;
            confirmBtn.innerHTML = 'Confirm';
        }
    }
}

// Utility functions
function updatePendingCount() {
    const badge = document.getElementById('pendingCount');
    badge.textContent = pendingRiders.length;
}

function filterRiders() {
    const searchTerm = document.getElementById('searchRiders').value.toLowerCase();
    const statusFilter = document.getElementById('statusFilter').value;
    
    const filtered = allRiders.filter(rider => {
        const matchesSearch = rider.fullName.toLowerCase().includes(searchTerm) ||
                            rider.email.toLowerCase().includes(searchTerm) ||
                            (rider.phoneNumber && rider.phoneNumber.includes(searchTerm));
        
        const matchesStatus = !statusFilter || rider.riderStatus === statusFilter;
        
        return matchesSearch && matchesStatus;
    });
    
    const container = document.getElementById('allRiders');
    if (filtered.length === 0) {
        container.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 2rem; color: #666;">
                <i class="fas fa-search" style="font-size: 3rem; margin-bottom: 1rem;"></i>
                <h3>No Riders Found</h3>
                <p>No riders match your search criteria.</p>
            </div>
        `;
    } else {
        container.innerHTML = filtered.map(rider => createRiderCard(rider)).join('');
    }
}

function formatDate(timestamp) {
    if (!timestamp) return 'N/A';
    
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // Add styles
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 1rem 1.5rem;
        border-radius: 5px;
        color: white;
        font-weight: 500;
        z-index: 3000;
        animation: slideIn 0.3s ease;
    `;
    
    if (type === 'success') {
        notification.style.background = '#28a745';
    } else if (type === 'error') {
        notification.style.background = '#dc3545';
    } else {
        notification.style.background = '#17a2b8';
    }
    
    document.body.appendChild(notification);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

// Add CSS animation
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
`;
document.head.appendChild(style); 