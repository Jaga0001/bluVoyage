# BluVoyage - AI-Powered Cultural Travel Planner

<div align="center">
  <img src="app/assets/app_logo.png" alt="BluVoyage Logo" width="120" height="120">
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.8.0+-blue.svg)](https://flutter.dev/)
  [![Python](https://img.shields.io/badge/Python-3.8+-brightgreen.svg)](https://python.org/)
  [![FastAPI](https://img.shields.io/badge/FastAPI-Latest-green.svg)](https://fastapi.tiangolo.com/)
  [![Firebase](https://img.shields.io/badge/Firebase-Integrated-orange.svg)](https://firebase.google.com/)
  [![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

## 🌟 Overview

BluVoyage is an intelligent travel planning application that leverages artificial intelligence to create personalized, culturally-rich travel experiences. Built for the QLOO Hackathon, it combines the power of AI recommendations with local cultural insights to craft unique itineraries tailored to individual preferences.

### ✨ Key Features

- **🤖 AI-Powered Itinerary Generation**: Creates personalized travel plans using advanced AI algorithms
- **🎭 Cultural Integration**: Incorporates local music, movies, and fashion recommendations
- **📱 Cross-Platform Mobile App**: Built with Flutter for iOS and Android
- **🔐 Google Authentication**: Secure login with Google Sign-In
- **☁️ Cloud Storage**: Firebase integration for data persistence
- **📄 PDF Export**: Generate and download travel itineraries as PDF documents
- **🎨 Modern UI/UX**: Beautiful, intuitive interface with smooth animations
- **🌐 Real-time API**: Fast and reliable backend with FastAPI

## 🏗️ Architecture

```
BluVoyage/
├── app/                    # Flutter Mobile Application
│   ├── lib/
│   │   ├── screens/        # UI Screens
│   │   ├── models/         # Data Models
│   │   ├── auth/           # Authentication Logic
│   │   ├── db/             # Database Functions
│   │   ├── apis/           # API Integration
│   │   └── services/       # Business Logic
│   ├── assets/             # Images and Resources
│   └── pubspec.yaml        # Flutter Dependencies
│
└── backend/                # Python FastAPI Server
    ├── main.py             # FastAPI Application
    ├── planner.py          # AI Travel Planning Logic
    └── requirements.txt    # Python Dependencies
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.8.0 or higher
- **Python**: Version 3.8 or higher
- **Node.js**: For Firebase CLI (optional)
- **Android Studio** or **Xcode**: For mobile development
- **Git**: For version control

### 🔧 Backend Setup

1. **Navigate to the backend directory**:
   ```bash
   cd backend
   ```

2. **Create a virtual environment**:
   ```bash
   python -m venv venv
   ```

3. **Activate the virtual environment**:
   - Windows:
     ```bash
     venv\Scripts\activate
     ```
   - macOS/Linux:
     ```bash
     source venv/bin/activate
     ```

4. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

5. **Set up environment variables**:
   Create a `.env` file in the backend directory:
   ```env
   QLOO_API_KEY=your_qloo_api_key_here
   GOOGLE_API_KEY=your_google_api_key_here
   PORT=10000
   ```

6. **Run the backend server**:
   ```bash
   python main.py
   ```

The API will be available at `http://localhost:10000`

### 📱 Mobile App Setup

1. **Navigate to the app directory**:
   ```bash
   cd app
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Add your `google-services.json` (Android) to `app/android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `app/ios/Runner/`
   - Update `firebase_options.dart` with your configuration

4. **Run the application**:
   ```bash
   flutter run
   ```

## 🔑 API Keys Setup

### Required API Keys

1. **QLOO API Key**: 
   - Sign up at [QLOO Developer Portal](https://qloo.com)
   - Get your API key for cultural recommendations

2. **Google API Key**:
   - Create a project in [Google Cloud Console](https://console.cloud.google.com)
   - Enable the Generative AI API
   - Create credentials and get your API key

3. **Firebase Configuration**:
   - Create a project in [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication and Firestore
   - Download configuration files

## 📊 Tech Stack

### Frontend (Mobile)
- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **Firebase Auth**: User authentication
- **Cloud Firestore**: NoSQL database
- **Google Fonts**: Typography
- **PDF Generation**: Document export

### Backend (API)
- **FastAPI**: Modern Python web framework
- **Google Generative AI**: AI-powered content generation
- **QLOO API**: Cultural recommendations
- **Uvicorn**: ASGI server
- **Aiohttp**: Async HTTP client

## 🌟 Features Deep Dive

### AI Itinerary Generation
The app uses Google's Generative AI to create comprehensive travel plans that include:
- Day-by-day activities and schedules
- Local attractions and landmarks
- Cultural experiences and events
- Restaurant recommendations
- Transportation suggestions

### Cultural Integration
Through QLOO API integration, the app provides:
- Local music artist recommendations
- Popular movies from the destination
- Fashion and style insights
- Cultural events and festivals

### User Experience
- **Smooth Animations**: Engaging UI transitions
- **Offline Support**: Cached data for offline viewing
- **PDF Export**: Share itineraries easily
- **Cloud Sync**: Access plans across devices

## 🔧 Development

### Running Tests
```bash
# Flutter tests
cd app
flutter test

# Python tests (if available)
cd backend
python -m pytest
```

### Building for Production

#### Android
```bash
cd app
flutter build apk --release
```

#### iOS
```bash
cd app
flutter build ios --release
```

#### Backend Deployment
The FastAPI backend is configured for deployment on platforms:
- Render

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style Guidelines
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style) for Flutter code
- Use [Black](https://black.readthedocs.io/) for Python code formatting
- Write meaningful commit messages
- Add tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎯 Roadmap

- [ ] **Multi-language Support**: Internationalization
- [ ] **Collaborative Planning**: Share and edit plans with friends
- [ ] **Expense Tracking**: Budget management features
- [ ] **Weather Integration**: Weather-based recommendations
- [ ] **AR Features**: Augmented reality city guides
- [ ] **Social Features**: Share experiences and reviews

## 🏆 Hackathon Context

This project was developed for the **QLOO Hackathon**, showcasing the integration of:
- QLOO's cultural recommendation API
- AI-powered content generation
- Modern mobile development practices
- Cloud-native architecture

## 📞 Support

For support, email [your-email@example.com] or create an issue in this repository.

## 🙏 Acknowledgments

- **QLOO** for providing the cultural recommendations API
- **Google** for Generative AI capabilities
- **Firebase** for backend infrastructure
- **Flutter Team** for the amazing framework

---

<div align="center">
  <strong>Made with ❤️ for travelers who seek authentic cultural experiences</strong>
</div>
