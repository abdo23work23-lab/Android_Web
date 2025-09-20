# Firebase CLI Commands Reference

Now that you're logged in as `abdo23.work23@gmail.com`, here are the essential commands:

## 🔧 Project Setup
```bash
# Set current project
firebase use parking-913c5

# List all your projects
firebase projects:list

# View current project info
firebase projects:info
```

## 🗄️ Firestore Database Commands
```bash
# Get all parking spaces
firebase firestore:data:get parking_spaces

# Get specific parking space
firebase firestore:data:get parking_spaces/alex_space_001

# Delete a document
firebase firestore:data:delete parking_spaces/document_id

# Import data from JSON
firebase firestore:data:load --collection parking_spaces data.json
```

## 🚀 Deployment Commands
```bash
# Deploy everything
firebase deploy

# Deploy only Firestore rules
firebase deploy --only firestore:rules

# Deploy only Firestore indexes
firebase deploy --only firestore:indexes

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

## 🔐 Authentication Commands
```bash
# List users
firebase auth:export users.json

# Create custom token
firebase auth:create-custom-token uid

# Delete user
firebase auth:delete uid
```

## 📊 Analytics and Monitoring
```bash
# View project usage
firebase projects:info

# Check functions logs (if you have functions)
firebase functions:log

# Check hosting logs
firebase hosting:site:list
```

## 🛠️ Development Tools
```bash
# Start local emulator
firebase emulators:start

# Start only Firestore emulator
firebase emulators:start --only firestore

# Initialize Firebase in new directory
firebase init
```

## 📝 Quick Data Operations

### Add Sample Parking Space
```bash
firebase firestore:data:set parking_spaces/new_space '{
  "name": "New Parking Location",
  "latitude": 31.2000,
  "longitude": 29.9000,
  "price_per_hour": 10.0,
  "available_spaces": 5,
  "total_spaces": 10,
  "status": "active"
}'
```

### Query Recent Reservations
```bash
firebase firestore:data:get reservations --limit 10 --order-by created_at desc
```

### Backup All Data
```bash
firebase firestore:export gs://parking-913c5.appspot.com/backup
```

## 🔍 Useful Flags
- `--project parking-913c5` - Specify project explicitly
- `--json` - Output in JSON format
- `--help` - Get help for any command
- `--debug` - Verbose debugging output

## 📱 Your Project URLs
- **Web App:** https://abdo23work23-lab.github.io/Android_Web/
- **Firebase Console:** https://console.firebase.google.com/project/parking-913c5
- **Admin Panel:** Built into your web app (Menu → Firebase Admin)

## 🎯 Common Tasks

### Initialize Sample Data
```bash
# Your app already does this, but you can also do it manually
firebase firestore:data:set parking_spaces/alex_space_001 '{
  "name": "Alexandria Marina Parking",
  "latitude": 31.2001,
  "longitude": 29.9187,
  "price_per_hour": 15.0,
  "available_spaces": 8,
  "total_spaces": 10,
  "status": "active"
}'
```

### Monitor Real-time Changes
```bash
# Use the built-in admin panel for real-time monitoring
# Or check the Firebase Console for live updates
```

## 🔐 Security Rules
Your current rules allow all access (for development). For production:
```bash
firebase deploy --only firestore:rules
```

Remember: You now have complete control over your Firebase project! 🎉