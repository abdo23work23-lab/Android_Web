# Parking Management App

A comprehensive Flutter application for parking management with Firebase integration.

## Features

- 🔐 **Authentication System**: Complete user authentication with Firebase Auth
- 📱 **Multi-platform Support**: Works on Android, iOS, Web, and Desktop
- 🗺️ **Google Maps Integration**: Location-based parking management
- 📷 **Camera Integration**: Photo capture for parking verification
- 🔔 **Real-time Updates**: Live data synchronization with Firebase Firestore
- 📊 **User Management**: Profile management and user preferences
- 🎨 **Modern UI**: Beautiful and responsive user interface

## Tech Stack

- **Frontend**: Flutter/Dart
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Maps**: Google Maps Flutter
- **State Management**: Provider
- **HTTP Client**: Dio
- **Image Processing**: Image Picker & Image package

## Getting Started

### Prerequisites

- Flutter SDK (>=3.3.4)
- Dart SDK
- Firebase project setup
- Google Maps API key

### Installation

1. Clone the repository:
```bash
git clone https://github.com/abdoemad23/Android.git
cd Android
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. Run the application:
```bash
flutter run
```

## Web Deployment

This project is configured for web deployment and can be accessed at:
[Live Demo](https://abdoemad23.github.io/Android/)

## Project Structure

```
lib/
├── helpers/          # API handlers and utilities
├── provider/         # State management
├── screens/          # UI screens
│   ├── auth/        # Authentication screens
│   ├── parking/     # Parking-related screens
│   └── profile/     # User profile screens
└── widgets/         # Reusable UI components
```

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Your Name - [@your_twitter](https://twitter.com/your_twitter) - email@example.com

Project Link: [https://github.com/abdoemad23/Android](https://github.com/abdoemad23/Android)
