<div align="center">

<img src="https://img.shields.io/badge/نور-Noor-1B5E20?style=for-the-badge&labelColor=2E7D32&color=1B5E20" height="40"/>

# Noor — نور
### AI-Powered Quran Emotional Guidance App

*"Let the Quran guide your heart"*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Django](https://img.shields.io/badge/Django-5.x-092E20?style=flat-square&logo=django)](https://djangoproject.com)
[![Claude AI](https://img.shields.io/badge/Claude-claude--opus--4--6-D97757?style=flat-square&logo=anthropic)](https://anthropic.com)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat-square&logo=python)](https://python.org)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

</div>

---

## 📱 Screenshots

<div align="center">

| Login Screen | Home Screen | Chat Screen | Ayah Detail |
|:---:|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/4c113811-e39c-4db2-b8b7-9b5f423d9993" width="180"/> | <img src="https://github.com/user-attachments/assets/d9708b79-dc20-4703-8172-d4e740ee4ae6" width="180"/> | <img src="https://github.com/user-attachments/assets/b56d7b4a-6108-4c36-93e2-67111e23ffb0" width="180"/> | <img src="https://github.com/user-attachments/assets/5f77a8b3-8a6e-40d4-8368-34464534daca" width="180"/> |

</div>

---

## ✨ What is Noor?

**Noor (نور)** means *light* in Arabic. This app is a spiritual companion that listens to your emotional state and responds with relevant Quranic ayahs — complete with Arabic text, translation, tafsir, and beautiful audio recitation by Sheikh Al-Afasy.

Whether you feel anxious, sad, grateful, or lost — Noor finds the Quran's guidance for your heart.

---

## 🌟 Features

| Feature | Description |
|---------|-------------|
| 🤲 **Emotional Guidance** | Share how you feel; receive 3 personally explained Quranic ayahs |
| 🧠 **Claude AI** | Powered by `claude-opus-4-6` with extended thinking for deep understanding |
| 🎵 **Audio Recitation** | Sheikh Al-Afasy's recitation streamed for each ayah |
| 🔖 **Favorites** | Save ayahs that resonate with you |
| 💬 **Chat History** | All sessions saved and accessible anytime |
| 🔐 **Google Sign-In** | Simple, secure authentication |
| 📖 **Arabic Text** | Full Arabic script with Amiri font |

---

## 🛠 Tech Stack

<div align="center">

| Layer | Technology |
|-------|-----------|
| **Mobile Frontend** | Flutter 3.x (Android & iOS) |
| **State Management** | Provider |
| **HTTP Client** | Dio with JWT interceptor |
| **Audio** | just_audio |
| **Backend** | Django 5 + Django REST Framework |
| **Database** | SQLite (dev) / PostgreSQL (prod) |
| **AI Engine** | Anthropic Claude `claude-opus-4-6` |
| **Authentication** | Google OAuth 2.0 + JWT |
| **Audio CDN** | Islamic Network (Sheikh Al-Afasy) |

</div>

---

## 📁 Project Structure

```
NOOR/
├── backend/                        # Django REST API
│   ├── authentication/             # Google OAuth + JWT
│   ├── chat/                       # Claude AI integration & sessions
│   ├── quran_data/                 # Ayah data & user favorites
│   ├── quran_app/                  # Project settings & URLs
│   ├── .env.example                # Environment template
│   └── requirements.txt
│
└── flutter_app/                    # Flutter mobile app
    └── lib/
        ├── config/                 # Theme & constants
        ├── models/                 # Data models (Ayah, User, Chat)
        ├── services/               # API, Auth, Audio services
        ├── providers/              # Auth & Chat state management
        ├── screens/                # Login, Home, Chat, Ayah Detail
        └── widgets/                # MessageBubble, AyahCard, AudioPlayer
```

---

## 🚀 Quick Start

### Prerequisites

- Python 3.10+
- Flutter 3.x SDK
- Android Studio / Xcode
- [Anthropic API key](https://console.anthropic.com)
- Google Cloud project with OAuth 2.0 configured

### 1. Clone the repository

```bash
git clone https://github.com/Arman170616/NOOR.git
cd NOOR
```

### 2. Configure environment

Copy the template and fill in your values:

```bash
cp backend/.env.example backend/.env
```

```env
SECRET_KEY=your-django-secret-key
DEBUG=True
ANTHROPIC_API_KEY=sk-ant-api03-...
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=your-android-client-id.apps.googleusercontent.com
```

### 3. Run the backend

```bash
cd backend
python -m venv venv
source venv/bin/activate          # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 0.0.0.0:8001
```

### 4. Configure Flutter

Update `flutter_app/lib/config/constants.dart`:

```dart
// For physical device — use your machine's local IP
static const String baseUrl = 'http://YOUR_LOCAL_IP:8001/api';

// Or use a tunnel for any network
static const String baseUrl = 'https://your-tunnel-url.serveousercontent.com/api';
```

### 5. Run the Flutter app

```bash
cd flutter_app
flutter pub get
flutter run
```

---

## 🔌 API Reference

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/auth/google/` | Sign in with Google ID token |
| `POST` | `/api/auth/refresh/` | Refresh JWT access token |
| `POST` | `/api/auth/logout/` | Logout & invalidate token |
| `GET` | `/api/auth/profile/` | Get current user profile |

### Chat
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/chat/sessions/` | List all chat sessions |
| `POST` | `/api/chat/sessions/` | Create new session |
| `GET` | `/api/chat/sessions/<id>/` | Get session messages |
| `POST` | `/api/chat/message/` | Send message, get AI response |

### Quran Data
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/quran/favorites/` | List saved favorites |
| `POST` | `/api/quran/favorites/add/` | Save an ayah |
| `DELETE` | `/api/quran/favorites/<id>/` | Remove a favorite |
| `GET` | `/api/quran/ayah/<surah>/<ayah>/` | Get ayah details |

---

## 🔑 Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create **OAuth 2.0 credentials**:
   - **Web application** client → use as `GOOGLE_WEB_CLIENT_ID`
   - **Android** client → add your package name + SHA-1 fingerprint
3. Get your debug SHA-1:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore \
     -alias androiddebugkey -storepass android -keypass android
   ```

---

## ⚙️ Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SECRET_KEY` | ✅ | Django secret key |
| `DEBUG` | ✅ | `True` for development |
| `ANTHROPIC_API_KEY` | ✅ | Claude AI API key |
| `GOOGLE_WEB_CLIENT_ID` | ✅ | Google OAuth web client |
| `GOOGLE_ANDROID_CLIENT_ID` | ✅ | Google OAuth Android client |
| `ALLOWED_HOSTS` | ✅ | Comma-separated allowed hosts |
| `CORS_ALLOWED_ORIGINS` | ⬜ | CORS origins for web clients |

---

## 💡 How It Works

```
User types: "I feel anxious about my future"
        │
        ▼
Claude claude-opus-4-6 analyzes emotion with extended thinking
        │
        ▼
Selects 3 Quranic ayahs most relevant to the emotional state
        │
        ▼
Returns: Arabic text + Translation + Personal tafsir explanation
        │
        ▼
Audio streamed from Islamic Network CDN (Sheikh Al-Afasy)
```

---

## 🌙 Islamic Design Philosophy

Noor is designed with respect for Islamic values:
- No music, only Quranic recitation
- Amiri Arabic font for proper Quranic text rendering
- Green color scheme inspired by Islamic tradition
- Bismillah displayed on the welcome screen
- All ayahs sourced from verified Quranic data

---

<div align="center">

Made with ❤️ for the Ummah

*"Indeed, with hardship will be ease."* — Quran 94:5

</div>
