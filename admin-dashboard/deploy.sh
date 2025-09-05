#!/bin/bash

# Gift Wave Admin Dashboard Deployment Script

echo "🚀 Deploying Gift Wave Admin Dashboard..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Check if user is logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo "🔐 Please login to Firebase..."
    firebase login
fi

# Initialize Firebase hosting if not already done
if [ ! -f "firebase.json" ]; then
    echo "📝 Initializing Firebase hosting..."
    firebase init hosting --public . --single-page-app false --yes
fi

# Deploy to Firebase
echo "📤 Deploying to Firebase hosting..."
firebase deploy --only hosting

echo "✅ Deployment complete!"
echo "🌐 Your admin dashboard is now live!"
echo "📖 Check the README.md for setup instructions." 