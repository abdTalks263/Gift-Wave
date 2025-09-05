# GiftWave - Pakistan's Premier Gift Delivery App

GiftWave is a modern iOS app built with SwiftUI and Firebase, specifically designed for the Pakistani market. It allows users to send gifts to loved ones across Pakistan via verified, uniformed delivery riders.

## 🇵🇰 Pakistan-Focused Features
- **Local Cities**: All major Pakistani cities and provinces
- **Local Currency**: PKR (Pakistani Rupees) with proper formatting
- **Cultural Gifts**: Eid, Ramadan, wedding, and traditional Pakistani gifts
- **Local Emergency Services**: Pakistan emergency numbers (15, 1122, 16)
- **CNIC Verification**: Pakistani National ID verification for riders
- **Local Delivery Fees**: Province and city-based pricing

## Features
- Sender and Rider user flows
- Firebase Authentication (email/phone)
- Rider verification and admin approval
- Gift order placement, tracking, and delivery
- MapKit for directions (extendable)
- Ratings and reviews
- Push notifications (extendable)

## 🔐 Security Features
- **User Verification**: Email/phone verification, rider KYC
- **Account Protection**: Login attempt limits, account blocking
- **Safety System**: Panic buttons, safety alerts, emergency contacts
- **Report System**: User reporting, misconduct handling
- **Data Protection**: Firestore security rules, encrypted storage
- **Real-time Monitoring**: Security logging, admin alerts
- **Location Security**: Token-based location access
- **Payment Security**: Secure payment handling (ready for Stripe integration)
- **Data Validation**: Real-time validation for CNIC, phone numbers, emails
- **OTP Verification**: 6-digit OTP verification for critical data (CNIC, phone, email)
- **Input Sanitization**: Prevents malicious data entry and ensures data integrity

## Folder Structure (MVVM)
```
Gift Wave/
  Models/
  ViewModels/
  Views/
    Authentication/
    Sender/
    Rider/
    Shared/
```

## Setup Instructions

### iOS App Setup
1. **Clone the repo** and open in Xcode.
2. **Add Firebase to your project:**
   - Go to [Firebase Console](https://console.firebase.google.com/), create a new project.
   - Add an iOS app, download `GoogleService-Info.plist`, and add it to the `Gift Wave` folder in Xcode.
   - Enable **Authentication** (Email/Password, Phone), **Firestore**, and **Storage** in Firebase Console.
3. **Configure Security:**
   - Deploy the `firestore.rules` to your Firestore database
   - Set up Firebase Storage rules for secure file uploads
   - Configure Firebase Authentication settings
4. **Dependencies:**
   - Use Swift Package Manager to add:
     - `https://github.com/firebase/firebase-ios-sdk.git`
   - Or use the provided `Package.swift`.
5. **Build and run** on iOS 16+.

### Admin Dashboard Setup
The admin functionality has been moved to a separate web-based dashboard for better management and accessibility.

**See `admin-dashboard/README.md` for complete setup instructions.**

Quick setup:
1. **Configure Firebase** in `admin-dashboard/config.js`
2. **Set up admin account** in Firebase Console
3. **Deploy** to any web hosting service
4. **Access** via web browser at your deployed URL

## Firestore Data Model
### Users Collection (`users`)
```
users/{userId}:
  id: string
  email: string
  phoneNumber: string
  fullName: string
  userType: "sender" | "rider"
  createdAt: timestamp
  // Rider fields
  cnic: string
  city: string
  riderStatus: "pending" | "approved" | "rejected" | "banned"
  profileImageURL: string
  averageRating: number
  totalDeliveries: number
```

### Orders Collection (`orders`)
```
orders/{orderId}:
  id: string
  senderId: string
  senderName: string
  senderPhone: string
  giftName: string
  productLink: string
  requestVideo: bool
  receiverName: string
  receiverAddress: string
  receiverCity: string
  receiverPhone: string
  deliveryFee: number
  tip: number
  totalAmount: number
  riderId: string
  riderName: string
  riderPhone: string
  status: "pending" | "accepted" | "purchased" | "inTransit" | "delivered" | "cancelled"
  createdAt: timestamp
  acceptedAt: timestamp
  deliveredAt: timestamp
  giftImageURL: string
  receiptImageURL: string
  reactionVideoURL: string
  pickupLocation: geopoint
  deliveryLocation: geopoint
  rating: number
  review: string
```

## Notes
- Admin panel can be managed via Firebase Console or a custom web app.
- Extend with FCM for push notifications, MapKit for navigation, and more.

## License
MIT 