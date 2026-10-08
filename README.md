# 🌾 Krishi Sahyog - Smart Crop Advisory App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white" alt="Firebase">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License">
</p>

<p align="center">
  <strong>A multilingual AI-powered mobile application providing intelligent crop advisory services to farmers with real-time weather monitoring, soil health analysis, and voice support.</strong>
</p>

## 🌟 Features

### 🔐 Authentication
- **Google Sign-In Integration** - Seamless authentication using Google OAuth
- **Mock User Support** - Test accounts for different user roles (Farmer, Advisor, Admin)
- **Biometric Login** - Fingerprint/Face ID support for enhanced security
- **Voice Input** - Voice-based login for low-literacy users

### 🌤️ Weather Dashboard
- **Real-time Weather Data** - Integration with OpenWeatherMap API
- **Location-based Forecasting** - GPS-based weather information
- **Agricultural Alerts** - Weather warnings specific to farming activities
- **Multi-language Support** - Hindi and English language options
- **Visual Weather Icons** - Day/night adaptive weather representations

### 🌱 Agricultural Services
- **Soil Health Monitoring** - Scan and analyze soil health report cards
- **Crop Advisory** - Personalized crop recommendations based on location and season
- **Pest Identification** - Camera-based pest and disease detection
- **Market Prices** - Real-time commodity pricing information

### 🎯 Smart Features
- **Voice Assistant** - AI-powered voice interaction in multiple languages
- **Offline Support** - Core features work without internet connectivity
- **Responsive Design** - Optimized for various screen sizes
- **Accessibility** - Designed for low-literacy users with voice and visual aids

## 🏗️ Technical Architecture

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: Provider Pattern
- **UI Components**: Material Design 3
- **Responsive Design**: Sizer package for adaptive layouts

### Backend & APIs
- **Authentication**: Firebase Auth with Google Sign-In
- **Weather API**: OpenWeatherMap API
- **Location Services**: Geolocator package
- **Voice Recognition**: Flutter TTS/STT integration

### Key Dependencies

dependencies:
flutter:
sdk: flutter
firebase_auth: ^4.19.4
google_sign_in: ^6.2.1
sizer: ^2.0.15
http: ^1.2.0
geolocator: ^11.0.0
permission_handler: ^11.3.1
intl: ^0.19.0

text

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x or higher)
- Android Studio / VS Code
- Firebase account
- OpenWeatherMap API key

### Installation

1. **Clone the repository**

git clone https://github.com/yourusername/Krishi-Sahyog.git
cd Krishi-Sahyog

text

2. **Install dependencies**

flutter pub get

text

3. **Firebase Setup**
- Create a new Firebase project
- Add Android app to Firebase project
- Download `google-services.json` and place in `android/app/`
- Enable Authentication > Google Sign-in

4. **API Configuration**
- Get OpenWeatherMap API key from [openweathermap.org](https://openweathermap.org/api)
- Add API key to `lib/services/weather_service.dart`

5. **Run the application**

flutter run

text

## 📱 Screenshots

<p align="center">
<img src="screenshots/login_screen.jpg" width="200" alt="Login Screen">
<img src="screenshots/dashboard.jpg" width="200" alt="Dashboard">
<img src="screenshots/weather.jpg" width="200" alt="Weather Dashboard">
<img src="screenshots/features.jpg" width="200" alt="Features">
</p>

## 🧪 Testing

### Test Accounts
Use these credentials for testing different user roles:

**Farmer Account:**
- Mobile: `9876543210`
- Password: `farmer123`

**Advisor Account:**
- Mobile: `9876543211`
- Password: `advisor123`

**Admin Account:**
- Mobile: `1234567890`
- Password: `123456`

### Running Tests

flutter test
flutter integration_test

text

## 🌐 API Integration

### Weather Service
The app integrates with OpenWeatherMap API for real-time weather data:
- Current weather conditions
- 5-day forecast
- Weather alerts
- Location-based weather data

### Authentication Flow
- Google OAuth 2.0 integration
- Firebase Authentication backend
- Secure token management
- Multi-device synchronization

## 🎨 UI/UX Design

### Design Principles
- **Simplicity**: Clean, intuitive interface for farmers
- **Accessibility**: Voice commands and visual aids
- **Localization**: Hindi and English language support
- **Responsiveness**: Works on various screen sizes

### Color Scheme
- Primary: Green (#4CAF50) - representing agriculture
- Secondary: Blue (#2196F3) - representing technology
- Accent: Orange (#FF9800) - for alerts and highlights

## 🔒 Security Features

- **Secure Authentication** - Firebase Auth with Google OAuth
- **Data Encryption** - All API communications encrypted
- **Permission Management** - Granular app permissions
- **Biometric Security** - Fingerprint/Face ID support

## 🌍 Localization

The app supports multiple languages:
- **Hindi** - Primary language for Indian farmers
- **English** - Secondary language option
- **Voice Support** - Audio in both languages

## 👥 Team

- **Lead Developer** - RiteshKumarRay
- **UI/UX Designer** - RiteshKumarRay
- **Agricultural Expert** - ShivamSinghYadav
- **Backend Developer** - ShivamSinghYadav

## 🙏 Acknowledgments

- **OpenWeatherMap** - Weather API services
- **Firebase** - Backend and authentication services
- **Flutter Team** - Amazing cross-platform framework
- **Agricultural Department** - Domain expertise and guidance

<p align="center">
  Made with ❤️ for farmers by the Krishi Sahyog team
  Its just a College Project
</p>

<p align="center">
  <a href="#top">⬆️ Back to Top</a>
</p>
