# Gift Wave Admin Dashboard

A web-based admin dashboard for managing rider applications and verifications for the Gift Wave delivery app.

## Features

- 🔐 **Secure Admin Authentication** - Firebase Auth integration
- 👥 **Rider Management** - View, approve, reject, and ban riders
- 📊 **Real-time Data** - Live updates from Firebase Firestore
- 🔍 **Search & Filter** - Find riders by name, email, or status
- 📝 **Verification History** - Complete audit trail of all actions
- 📱 **Responsive Design** - Works on desktop, tablet, and mobile
- 🎨 **Modern UI** - Clean, professional interface

## Setup Instructions

### 1. Firebase Configuration

1. **Get your Firebase config** from your Firebase Console:
   - Go to Project Settings > General
   - Scroll down to "Your apps" section
   - Copy the config object

2. **Update `config.js`**:
   ```javascript
   const firebaseConfig = {
       apiKey: "your-api-key",
       authDomain: "your-project.firebaseapp.com",
       projectId: "your-project-id",
       storageBucket: "your-project.appspot.com",
       messagingSenderId: "your-sender-id",
       appId: "your-app-id"
   };
   ```

### 2. Firestore Security Rules

Make sure your Firestore rules allow admin access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin collections
    match /admins/{adminId} {
      allow read, write: if request.auth != null && request.auth.uid == adminId;
    }
    
    // User data for admin access
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    
    // Verification actions
    match /rider_verification_actions/{actionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. Admin Account Setup

1. **Create admin user in Firebase Auth**:
   - Go to Firebase Console > Authentication > Users
   - Add a new user with admin email and password

2. **Create admin document in Firestore**:
   ```javascript
   // In Firestore Console, create a document in 'admins' collection
   // Document ID should match the Firebase Auth UID
   {
     "email": "admin@giftwave.com",
     "fullName": "Gift Wave Administrator",
     "role": "super_admin",
     "isActive": true,
     "createdAt": "timestamp"
   }
   ```

### 4. Deployment

#### Option A: Local Development
1. Install a local server (e.g., `python -m http.server 8000`)
2. Open `http://localhost:8000` in your browser

#### Option B: Firebase Hosting (Recommended)
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize: `firebase init hosting`
4. Deploy: `firebase deploy`

#### Option C: Any Web Server
Upload the files to any web hosting service (Netlify, Vercel, etc.)

## Usage

### Login
- Use your admin email and password
- The system will verify you have admin privileges

### Dashboard Tabs

#### Pending Riders
- View all rider applications awaiting approval
- Click on any rider card to see details
- Approve, reject, or ban riders with reasons

#### All Riders
- View all registered riders
- Search by name, email, or phone
- Filter by status (pending, approved, rejected, banned)

#### Verification History
- Complete audit trail of all admin actions
- See who performed what action and when
- Track reasons for rejections/bans

#### Profile
- View your admin account details
- See your role and permissions

### Actions

#### Approve Rider
- Click "Approve" button
- Rider status changes to "approved"
- Rider can now use the app

#### Reject Rider
- Click "Reject" button
- Provide a reason (required)
- Rider status changes to "rejected"
- Rider sees rejection reason when trying to login

#### Ban Rider
- Click "Ban" button
- Provide a reason (required)
- Rider status changes to "banned"
- Rider cannot use the app

## Security Features

- ✅ **Firebase Auth** - Secure authentication
- ✅ **Admin-only access** - Only authorized admins can access
- ✅ **Audit trail** - All actions are logged
- ✅ **Input validation** - Prevents malicious input
- ✅ **HTTPS required** - Secure data transmission

## File Structure

```
admin-dashboard/
├── index.html          # Main HTML file
├── styles.css          # CSS styles
├── config.js           # Firebase configuration
├── app.js              # Main JavaScript application
└── README.md           # This file
```

## Troubleshooting

### Common Issues

1. **"Access denied" error**
   - Make sure admin document exists in Firestore
   - Check that document ID matches Firebase Auth UID

2. **"Firebase not initialized" error**
   - Verify Firebase config in `config.js`
   - Check that all Firebase SDK scripts are loaded

3. **"Permission denied" error**
   - Update Firestore security rules
   - Ensure admin user has proper permissions

4. **Data not loading**
   - Check browser console for errors
   - Verify Firestore collections exist
   - Check network connectivity

### Support

For technical support, check:
1. Browser console for error messages
2. Firebase Console for authentication issues
3. Firestore Console for data access problems

## Development

### Adding New Features

1. **New Admin Actions**: Add functions in `app.js`
2. **UI Changes**: Modify `styles.css` and `index.html`
3. **Data Structure**: Update Firestore collections as needed

### Testing

1. **Local Testing**: Use Firebase Emulator Suite
2. **Production Testing**: Use staging Firebase project
3. **Browser Testing**: Test on Chrome, Firefox, Safari, Edge

## License

This admin dashboard is part of the Gift Wave delivery app project. 