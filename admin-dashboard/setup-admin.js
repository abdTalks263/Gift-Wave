// Admin Setup Script
const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const auth = admin.auth();
const db = admin.firestore();

// Admin user configuration
const adminUser = {
  email: 'admin@giftwave.com',
  password: 'admin123!@#',
  displayName: 'Gift Wave Administrator'
};

async function setupAdmin() {
  try {
    // Get or create admin user
    let userRecord;
    try {
      // Try to get existing user
      userRecord = await auth.getUserByEmail(adminUser.email);
      console.log('Found existing admin user');
      
      // Update password if user exists
      await auth.updateUser(userRecord.uid, {
        password: adminUser.password,
        displayName: adminUser.displayName,
        emailVerified: true
      });
      console.log('Updated admin user credentials');
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        // Create new user if doesn't exist
        userRecord = await auth.createUser({
          email: adminUser.email,
          password: adminUser.password,
          displayName: adminUser.displayName,
          emailVerified: true
        });
        console.log('Created new admin user');
      } else {
        throw error;
      }
    }

    // Create or update admin document in Firestore
    await db.collection('admins').doc(userRecord.uid).set({
      email: adminUser.email,
      fullName: adminUser.displayName,
      role: 'super_admin',
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    console.log('Admin setup completed successfully. User ID:', userRecord.uid);
    process.exit(0);
  } catch (error) {
    console.error('Error setting up admin:', error);
    process.exit(1);
  }
}

setupAdmin();
