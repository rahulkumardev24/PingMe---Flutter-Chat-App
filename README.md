# Ping Me - Flutter Chat Application

Ping Me is a modern, real-time chat application built with Flutter and Firebase. It allows users to send text messages, images, and emojis in real-time. The app features user authentication, online/offline status, and a clean, intuitive UI.

## ✨ Features

- 🔐 **Google Sign-In** - Secure authentication using Google Sign-In
- 💬 **Real-time Messaging** - Instant message delivery using Firebase Cloud Firestore
- 📷 **Image Sharing** - Send and receive images in chats
- 😊 **Emoji Support** - Express yourself with emojis
- 👥 **User Profiles** - View and update user profiles
- 🟢 **Online/Offline Status** - See when users are active
- 🔍 **Search Users** - Easily find and start conversations
- 📱 **Responsive Design** - Works on both mobile and tablet devices

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Firebase project with Cloud Firestore and Authentication enabled
- Android Studio / Xcode (for emulator/simulator)
- Physical device (for testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ping_me.git
   cd ping_me
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a new project in the [Firebase Console](https://console.firebase.google.com/)
   - Add an Android/iOS app to your Firebase project
   - Download the `google-services.json` file and place it in `android/app/`
   - Follow the setup instructions for iOS if needed

4. **Run the app**
   ```bash
   flutter run
   ```

## 🛠️ Project Structure

```
lib/
├── api/                  # API services and configurations
├── helper/               # Helper classes and utilities
├── model/                # Data models
├── screen/               # App screens
│   ├── auth/             # Authentication screens
│   └── ...               # Other screens
├── utils/                # Utility classes and constants
├── widgets/              # Reusable widgets
├── firebase_options.dart # Firebase configuration
└── main.dart            # Entry point of the application
```

## 📱 Screenshots

| Login Screen | Home Screen | Chat Screen |
|-------------|-------------|-------------|
| <img src="screenshots/login_screen.png" width="200"> | <img src="screenshots/home_screen.png" width="200"> | <img src="screenshots/chat_screen.png" width="200"> |

## 🔧 Dependencies

- `firebase_core`: ^3.13.0
- `firebase_auth`: ^5.5.2
- `cloud_firestore`: ^5.6.6
- `google_sign_in`: ^6.3.0
- `firebase_messaging`: ^15.2.5
- `cached_network_image`: ^3.2.3
- `image_picker`: ^1.1.2
- `firebase_storage`: ^12.4.5
- `intl`: ^0.20.2
- `emoji_picker_flutter`: ^4.3.0
- `gallery_saver_plus`: ^3.2.1

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Flutter Community](https://flutter.dev/community)
