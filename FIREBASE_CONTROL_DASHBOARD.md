# Firebase Control Dashboard

## 🎯 Quick Links
- **Firebase Console:** https://console.firebase.google.com/project/parking-913c5  
- **Your Live App:** https://abdo23work23-lab.github.io/Android_Web/
- **GitHub Repo:** https://github.com/abdo23work23-lab/Android_Web

## 🔥 Firebase Console Control

### 1. **Database Management**
**Firestore Database** → **Data**
- View/edit collections: `parking_spaces`, `reservations`, `vehicles`
- Real-time data monitoring
- Query and filter data

### 2. **User Authentication**
**Authentication** → **Users**
- Manage user accounts
- View login history
- Configure providers

### 3. **Analytics & Monitoring**
**Analytics** → **Dashboard**
- User activity tracking
- App usage statistics
- Performance monitoring

### 4. **Security Rules**
**Firestore Database** → **Rules**
Current rules (open for testing):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## 🛠️ Firebase CLI Control

### Login (Manual Step Required)
```bash
# You need to run this interactively in your terminal
firebase login

# Then use your project
firebase use parking-913c5
```

### Database Operations
```bash
# View project info
firebase projects:list

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy to Firebase Hosting (alternative to GitHub Pages)
firebase deploy --only hosting

# View logs
firebase functions:log
```

## 📊 Sample Data Operations

### Create Sample Parking Spaces
Use Firebase Console → Firestore → Create Collection:

**Collection ID:** `parking_spaces`
**Document 1:**
```json
{
  "id": "alex_space_001",
  "name": "Alexandria Marina Parking",
  "description": "Premium parking near Alexandria Marina",
  "latitude": 31.2001,
  "longitude": 29.9187,
  "price_per_hour": 15.0,
  "available_spaces": 8,
  "total_spaces": 10,
  "status": "active",
  "amenities": ["security", "covered", "ev_charging"],
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z"
}
```

**Document 2:**
```json
{
  "id": "alex_space_002", 
  "name": "Citadel Parking Area",
  "description": "Historic area parking near Qaitbay Citadel",
  "latitude": 31.2144,
  "longitude": 29.8853,
  "price_per_hour": 12.0,
  "available_spaces": 5,
  "total_spaces": 6,
  "status": "active",
  "amenities": ["security", "24/7"],
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z"
}
```

### Authentication Setup
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Enable **Anonymous** (for testing)
4. Add authorized domain: `abdo23work23-lab.github.io`

## 🔧 Advanced Operations

### Create Composite Indexes
Navigate to **Firestore** → **Indexes** → **Composite**

**Index 1:** parking_spaces
- Collection: `parking_spaces`
- Fields: `status` (Ascending), `latitude` (Ascending), `longitude` (Ascending)

**Index 2:** reservations  
- Collection: `reservations`
- Fields: `user_id` (Ascending), `created_at` (Descending)

**Index 3:** vehicles
- Collection: `vehicles`
- Fields: `user_id` (Ascending), `is_default` (Descending)

## 📱 Testing Your App
1. Open: https://abdo23work23-lab.github.io/Android_Web/
2. Navigate to parking management
3. Test real-time data synchronization
4. Verify CRUD operations

## 🚨 Security Notes
- Current rules allow all access (for testing only)
- For production, implement proper authentication rules
- Admin SDK key is safely excluded from repository

## 📞 Support
If you need help with specific Firebase operations, I can:
- ✅ Guide you through console operations
- ✅ Create/modify Flutter code for Firebase integration
- ✅ Help with data modeling and queries
- ✅ Assist with deployment and configuration