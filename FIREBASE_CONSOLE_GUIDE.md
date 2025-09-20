# Firebase Console Control Guide

## 🚀 Quick Access
**Your Firebase Console:** https://console.firebase.google.com/project/parking-913c5

## 📊 Essential Operations

### 1. **Firestore Database**
- Navigate to: **Firestore Database** → **Data**
- Create collections: `parking_spaces`, `reservations`, `vehicles`
- Add sample data as needed

### 2. **Authentication Setup**
- Go to: **Authentication** → **Sign-in method**
- Enable: Email/Password, Google, Anonymous
- Configure authorized domains

### 3. **Create Required Indexes**
Navigate to **Firestore Database** → **Indexes** → **Composite** and create:

```javascript
// Index 1: parking_spaces
Collection: parking_spaces
Fields: status (Ascending), latitude (Ascending), longitude (Ascending)

// Index 2: reservations  
Collection: reservations
Fields: user_id (Ascending), created_at (Descending)

// Index 3: vehicles
Collection: vehicles  
Fields: user_id (Ascending), is_default (Descending), created_at (Descending)
```

### 4. **Security Rules**
Update Firestore rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to all users (for testing)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### 5. **Add Sample Data**
You can manually add the sample parking spaces from your app's FirebaseInitializer.

## 🔧 Firebase CLI Commands
```bash
# Login to Firebase
firebase login

# View projects
firebase projects:list

# Set current project
firebase use parking-913c5

# Deploy security rules
firebase deploy --only firestore:rules
```

## 📱 Real-time Monitoring
- **Usage** → Dashboard for analytics
- **Firestore** → Data to see live data changes
- **Authentication** → Users to manage users