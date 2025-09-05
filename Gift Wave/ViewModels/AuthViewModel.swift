//
//  AuthViewModel.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showVerificationAlert = false
    @Published var showTwoFactorSetup = false
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    // Security constants
    private let maxLoginAttempts = 5
    private let lockoutDuration: TimeInterval = 15 * 60 // 15 minutes
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            Task {
                if let user = user {
                    await self?.fetchUserData(userId: user.uid)
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // First attempt to sign in
            let result = try await auth.signIn(withEmail: email, password: password)
            
            // After successful sign in, fetch fresh user data
            await fetchUserData(userId: result.user.uid)
            
            // Now check the user status with fresh data
            if let currentUser = self.currentUser {
                // Check if user is blocked
                if currentUser.isBlocked {
                    errorMessage = "Account is blocked: \(currentUser.blockedReason ?? "Contact support")"
                    try await auth.signOut()
                    self.currentUser = nil
                    isAuthenticated = false
                    isLoading = false
                    return
                }
                
                // Check rider status
                if currentUser.userType == .rider, let riderStatus = currentUser.riderStatus {
                    switch riderStatus {
                    case .rejected:
                        let reason = currentUser.statusReason ?? "No reason provided"
                        errorMessage = "Your rider application was rejected. Reason: \(reason). Please contact support if you believe this is an error."
                        try await auth.signOut()
                        self.currentUser = nil
                        isAuthenticated = false
                        isLoading = false
                        return
                    case .banned:
                        errorMessage = "Your rider account has been banned. Please contact support for more information."
                        try await auth.signOut()
                        self.currentUser = nil
                        isAuthenticated = false
                        isLoading = false
                        return
                    case .pending:
                        errorMessage = "Your rider application is still pending review. Please wait for admin approval."
                        try await auth.signOut()
                        self.currentUser = nil
                        isAuthenticated = false
                        isLoading = false
                        return
                    case .approved:
                        // Continue with login
                        break
                    }
                }
                
                // If we get here, the user is allowed to log in
                await updateLoginInfo(userId: result.user.uid)
                isAuthenticated = true
                errorMessage = nil
            }
            
        } catch {
            // Increment failed login attempts
            await incrementLoginAttempts(email: email)
            errorMessage = error.localizedDescription
            self.currentUser = nil
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String, fullName: String, phoneNumber: String, userType: UserType) async {
        isLoading = true
        errorMessage = nil
        
        print("🚀 Starting sign up process for: \(email)")
        
        do {
            // Create Firebase Auth user
            print("📝 Creating Firebase Auth user...")
            let result = try await auth.createUser(withEmail: email, password: password)
            print("✅ Firebase Auth user created: \(result.user.uid)")
            
            // Create User object
            let user = User(email: email, phoneNumber: phoneNumber, fullName: fullName, userType: userType)
            print("👤 User object created: \(user.fullName)")
            
            // Save to Firestore
            try await saveUserToFirestore(user: user, userId: result.user.uid)
            
            // Fetch user data to confirm
            await fetchUserData(userId: result.user.uid)
            
        } catch {
            print("❌ Sign up failed: \(error)")
            errorMessage = "Sign up failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func registerRider(riderRegistration: RiderRegistration, password: String) async {
        isLoading = true
        errorMessage = nil
        
        print("🚀 Starting rider registration for: \(riderRegistration.email)")
        
        do {
            // Create Firebase Auth user
            print("📝 Creating Firebase Auth user...")
            let result = try await auth.createUser(withEmail: riderRegistration.email, password: password)
            print("✅ Firebase Auth user created: \(result.user.uid)")
            
            // Upload profile image first if provided
            var profileImageURL: String? = nil
            if let imageData = riderRegistration.profileImageData {
                print("📷 Uploading profile image...")
                profileImageURL = try await uploadProfileImage(imageData: imageData, userId: result.user.uid)
                print("✅ Profile image uploaded successfully")
            }
            
            // Create User object with profile image URL
            let user = User(rider: riderRegistration, profileImageURL: profileImageURL)
            print("👤 User object created for rider: \(user.fullName)")
            
            // Save complete user data to Firestore
            try await saveUserToFirestore(user: user, userId: result.user.uid)
            
            // Fetch updated user data
            await fetchUserData(userId: result.user.uid)
            print("✅ Rider registration completed successfully")
            
        } catch {
            print("❌ Rider registration failed: \(error)")
            
            // Provide specific error messages for common issues
            if error.localizedDescription.contains("email address is already in use") {
                errorMessage = "This email is already registered. Please use a different email or try logging in instead."
            } else if error.localizedDescription.contains("weak password") {
                errorMessage = "Password is too weak. Please use at least 6 characters with a mix of letters and numbers."
            } else if error.localizedDescription.contains("invalid email") {
                errorMessage = "Please enter a valid email address."
            } else if error.localizedDescription.contains("network") {
                errorMessage = "Network error. Please check your internet connection and try again."
            } else {
                errorMessage = "Registration failed: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try auth.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func fetchUserData(userId: String) async {
        do {
            print("🔍 Fetching user data for ID: \(userId)")
            
            let document = try await db.collection("users").document(userId).getDocument()
            
            if document.exists {
                if let data = document.data() {
                    print("📄 User data found with \(data.keys.count) fields")
                    
                    // Try to decode the user data
                    do {
                        let user = try document.data(as: User.self)
                        print("✅ User decoded successfully: \(user.fullName)")
                        currentUser = user
                        isAuthenticated = true
                        errorMessage = nil
                    } catch {
                        print("❌ Failed to decode user data: \(error)")
                        
                        // Fallback: try to create user with basic fields
                        if let email = data["email"] as? String,
                           let phoneNumber = data["phoneNumber"] as? String,
                           let fullName = data["fullName"] as? String,
                           let userTypeString = data["userType"] as? String {
                            
                            let userType = UserType(rawValue: userTypeString) ?? .sender
                            let user = User(
                                email: email,
                                phoneNumber: phoneNumber,
                                fullName: fullName,
                                userType: userType
                            )
                            
                            print("✅ User created with fallback method: \(user.fullName)")
                            currentUser = user
                            isAuthenticated = true
                            errorMessage = nil
                        } else {
                            errorMessage = "User data is incomplete. Please contact support."
                        }
                    }
                } else {
                    print("❌ Document exists but no data")
                    errorMessage = "User document exists but contains no data"
                }
            } else {
                print("❌ User document does not exist for ID: \(userId)")
                errorMessage = "User account not found. Please try logging in again or contact support."
                
                // Sign out the user since their data doesn't exist
                try auth.signOut()
                currentUser = nil
                isAuthenticated = false
            }
        } catch {
            print("❌ Failed to fetch user data: \(error)")
            
            // Provide more specific error messages
            if error.localizedDescription.contains("permission") {
                errorMessage = "Access denied. Please contact support."
            } else if error.localizedDescription.contains("network") || error.localizedDescription.contains("connection") {
                errorMessage = "Network error. Please check your internet connection and try again."
            } else {
                errorMessage = "Failed to load user data. Please try again."
            }
        }
    }
    
    private func saveUserToFirestore(user: User, userId: String) async throws {
        print("💾 Saving user to Firestore: \(userId)")
        
        var userData = user
        userData.id = userId
        
        do {
            // Convert to dictionary to see what we're actually saving
            let encoder = Firestore.Encoder()
            let userDict = try encoder.encode(userData)
            print("📄 Saving user data: \(userDict)")
            
            // Try to save to Firestore
            try await db.collection("users").document(userId).setData(from: userData)
            print("✅ User saved successfully to Firestore")
            
            // Also save a simple version to verify
            let simpleData: [String: Any] = [
                "email": userData.email,
                "fullName": userData.fullName,
                "userType": userData.userType.rawValue,
                "createdAt": Date()
            ] as [String: Any]
            
            try await db.collection("users").document(userId).updateData(simpleData)
            print("✅ Simple user data also saved")
            
        } catch {
            print("❌ Failed to save user to Firestore: \(error)")
            throw error
        }
    }
    
    func uploadProfileImage(imageData: Data, userId: String) async throws -> String {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("profile_images/\(userId).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await imageRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    private func updateUserProfileImage(userId: String, imageURL: String) async throws {
        try await db.collection("users").document(userId).updateData([
            "profileImageURL": imageURL
        ])
    }
    
    // MARK: - Email Checking Methods
    
    func checkEmailExists(email: String) async -> Bool {
        do {
            let snapshot = try await db.collection("users")
                .whereField("email", isEqualTo: email)
                .getDocuments()
            
            return !snapshot.documents.isEmpty
        } catch {
            print("❌ Error checking email existence: \(error)")
            return false
        }
    }
    

    
    // MARK: - Security Methods
    
    private func getUserByEmail(email: String) async -> User? {
        do {
            let snapshot = try await db.collection("users")
                .whereField("email", isEqualTo: email)
                .getDocuments()
            
            return try snapshot.documents.first?.data(as: User.self)
        } catch {
            return nil
        }
    }
    
    private func incrementLoginAttempts(email: String) async {
        do {
            let snapshot = try await db.collection("users")
                .whereField("email", isEqualTo: email)
                .getDocuments()
            
            if let document = snapshot.documents.first {
                let currentAttempts = document.data()["loginAttempts"] as? Int ?? 0
                let newAttempts = currentAttempts + 1
                
                try await document.reference.updateData([
                    "loginAttempts": newAttempts,
                    "updatedAt": Date()
                ])
                
                // Block account if max attempts reached
                if newAttempts >= maxLoginAttempts {
                    try await document.reference.updateData([
                        "isBlocked": true,
                        "blockedReason": "Too many failed login attempts"
                    ])
                }
            }
        } catch {
            print("Failed to update login attempts: \(error)")
        }
    }
    
    private func updateLoginInfo(userId: String) async {
        do {
            try await db.collection("users").document(userId).updateData([
                "lastLoginAt": Date(),
                "loginAttempts": 0,
                "updatedAt": Date()
            ])
        } catch {
            print("Failed to update login info: \(error)")
        }
    }
    
    func enableTwoFactor(userId: String) async {
        do {
            try await db.collection("users").document(userId).updateData([
                "twoFactorEnabled": true,
                "updatedAt": Date()
            ])
        } catch {
            print("Failed to enable 2FA: \(error)")
        }
    }
    
    func verifyEmail(userId: String) async {
        do {
            try await db.collection("users").document(userId).updateData([
                "isEmailVerified": true,
                "updatedAt": Date()
            ])
        } catch {
            print("Failed to verify email: \(error)")
        }
    }
    
    func verifyPhone(userId: String) async {
        do {
            try await db.collection("users").document(userId).updateData([
                "isPhoneVerified": true,
                "updatedAt": Date()
            ])
        } catch {
            print("Failed to verify phone: \(error)")
        }
    }
    
    func updateProfile(userId: String, fullName: String, phoneNumber: String, city: String, profileImageURL: String? = nil) async throws {
        var updateData: [String: Any] = [
            "fullName": fullName,
            "phoneNumber": phoneNumber,
            "city": city,
            "updatedAt": Date()
        ]
        
        if let imageURL = profileImageURL {
            updateData["profileImageURL"] = imageURL
        }
        
        try await db.collection("users").document(userId).updateData(updateData)
        await fetchUserData(userId: userId)
    }
    
    // MARK: - Debug Methods
    
    func testFirebaseConnection() async {
        print("🔧 Testing Firebase connection...")
        
        do {
            // Test 1: Check if Firestore is enabled
            print("📡 Testing Firestore availability...")
            let testDoc = try await db.collection("test").document("connection").getDocument()
            print("✅ Firestore is available")
            
            // Test 2: Firebase Auth connection
            print("🔐 Testing Firebase Auth connection...")
            let currentUser = auth.currentUser
            print("✅ Firebase Auth connection successful. Current user: \(currentUser?.uid ?? "None")")
            
            // Test 3: Simple write test
            print("✍️ Testing simple write...")
            let testData: [String: Any] = [
                "message": "Hello Firebase!",
                "timestamp": Date(),
                "test": true
            ]
            
            try await db.collection("test").document("simple-test").setData(testData)
            print("✅ Simple write successful")
            
            // Test 4: Read the test document
            print("📖 Testing read...")
            let readTest = try await db.collection("test").document("simple-test").getDocument()
            if let data = readTest.data() {
                print("✅ Read successful: \(data)")
            } else {
                print("⚠️ Document exists but no data")
            }
            
            // Test 5: Check if we can see the document in console
            print("🔍 Checking document in Firestore...")
            let allTestDocs = try await db.collection("test").getDocuments()
            print("📄 All test documents: \(allTestDocs.documents.count) found")
            for doc in allTestDocs.documents {
                print("   - \(doc.documentID): \(doc.data())")
            }
            
            print("🎉 Basic Firebase tests passed!")
            errorMessage = nil
            
        } catch {
            print("❌ Firebase connection failed: \(error)")
            errorMessage = "Firebase connection failed: \(error.localizedDescription)"
        }
    }
} 