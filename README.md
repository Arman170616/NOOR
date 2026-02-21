# Noor (نور) — AI-Powered Quran Emotional Guidance App

An Islamic mobile application that provides personalized Quranic guidance based on emotional states, powered by Claude AI.

## Features

- **Emotional Guidance**: Share how you feel and receive relevant Quranic ayahs
- **AI-Powered**: Claude `claude-opus-4-6` with extended thinking for deep understanding
- **Audio Recitation**: Listen to Sheikh Al-Afasy's recitation of each ayah
- **Save Favorites**: Bookmark ayahs that resonate with you
- **Conversation History**: All sessions are saved and accessible
- **Google Sign-In**: Simple and secure authentication

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Django 5 + Django REST Framework |
| Database | SQLite (development) |
| AI | Anthropic Claude `claude-opus-4-6` |
| Auth | Google OAuth + JWT |
| Frontend | Flutter (Android & iOS) |
| State | Provider |
| HTTP | Dio with JWT interceptor |
| Audio | just_audio |

## Project Structure

```
AL-Quran/
├── backend/                    # Django REST API
│   ├── quran_app/             # Project settings & URLs
│   ├── authentication/        # Google OAuth + JWT auth
│   ├── chat/                  # Claude AI integration
│   ├── quran_data/            # Quran data & favorites
│   ├── .env                   # Environment variables
│   └── requirements.txt
│
└── flutter_app/               # Flutter mobile app
    └── lib/
        ├── config/            # Theme & constants
        ├── models/            # Data models
        ├── services/          # API, Auth, Audio services
        ├── providers/         # State management
        ├── screens/           # UI screens
        └── widgets/           # Reusable widgets
```

## Quick Start

### Prerequisites

- Python 3.10+
- Flutter 3.x
- Android Studio / Xcode
- Anthropic API key
- Google Cloud project with OAuth configured

### 1. Clone & Configure

```bash
cd AL-Quran
```

Create `backend/.env`:
```env
SECRET_KEY=your-django-secret-key-here
DEBUG=True
ANTHROPIC_API_KEY=sk-ant-api03-...
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=140560791771-iojtfce8196hq7duhr7avos5gjpt6idb.apps.googleusercontent.com
```

### 2. Run Setup Script

```bash
chmod +x setup.sh
./setup.sh
```

### 3. Start the Backend

```bash
cd backend
source venv/bin/activate
python manage.py runserver 0.0.0.0:8000
```

### 4. Configure Flutter

Update `flutter_app/lib/config/constants.dart` with your machine's IP:
```dart
static const String baseUrl = 'http://YOUR_IP:8000/api';
```

### 5. Run the Flutter App

```bash
cd flutter_app
flutter run
```

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/google/` | Google Sign-In |
| POST | `/api/auth/refresh/` | Refresh JWT token |
| POST | `/api/auth/logout/` | Logout |
| GET | `/api/auth/profile/` | Get user profile |

### Chat
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/chat/sessions/` | List sessions |
| POST | `/api/chat/sessions/` | Create session |
| GET | `/api/chat/sessions/<id>/` | Get session messages |
| POST | `/api/chat/message/` | Send message |

### Quran Data
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/quran/favorites/` | List favorites |
| POST | `/api/quran/favorites/add/` | Add favorite |
| DELETE | `/api/quran/favorites/<id>/` | Remove favorite |
| GET | `/api/quran/ayah/<surah>/<ayah>/` | Get ayah details |

## Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create OAuth 2.0 credentials:
   - **Web client** (for backend verification)
   - **Android client** with SHA-1 fingerprint
3. For Android SHA-1:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
4. Add `google-services.json` to `flutter_app/android/app/`

## Environment Variables

| Variable | Description |
|----------|-------------|
| `SECRET_KEY` | Django secret key |
| `DEBUG` | Debug mode (`True`/`False`) |
| `ANTHROPIC_API_KEY` | Claude AI API key |
| `GOOGLE_WEB_CLIENT_ID` | Google OAuth web client ID |
| `GOOGLE_ANDROID_CLIENT_ID` | Google OAuth Android client ID |

## How It Works

1. User types their emotional state (e.g., "I feel anxious about my future")
2. Claude analyzes the emotion with extended thinking
3. Claude selects 3 relevant Quranic ayahs with Arabic text, translation, and personal explanation
4. Audio recitation is loaded from Islamic Network CDN
5. User can save favorite ayahs and replay conversations

## Development Notes

- All Flutter IDE errors ("Target of URI doesn't exist") resolve after `flutter pub get`
- The backend uses SQLite by default — switch to PostgreSQL for production
- Claude uses `thinking: {type: "adaptive"}` for nuanced emotional understanding
- JWT access tokens expire in 60 minutes; refresh tokens last 7 days
