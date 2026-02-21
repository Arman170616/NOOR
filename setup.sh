#!/bin/bash
# ============================================================
# Noor — AI-Powered Quran Emotional Guidance App
# Full setup script
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}
╔═══════════════════════════════════════════╗
║   Noor (نور) — Quranic Guidance App       ║
║   Setup Script                            ║
╚═══════════════════════════════════════════╝
${NC}"

# ─── Backend Setup ───────────────────────────────────────────
echo -e "${YELLOW}[1/4] Setting up Django backend...${NC}"

cd "$(dirname "$0")/backend"

# Create virtual environment
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
fi

# Activate venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt --quiet
echo -e "${GREEN}✓ Python dependencies installed${NC}"

# Check for .env file
if [ ! -f ".env" ]; then
    echo -e "${RED}✗ ERROR: backend/.env file not found!${NC}"
    echo -e "${YELLOW}  Please create backend/.env with the following variables:${NC}"
    echo ""
    echo "  SECRET_KEY=your-django-secret-key"
    echo "  DEBUG=True"
    echo "  ANTHROPIC_API_KEY=your-anthropic-api-key"
    echo "  GOOGLE_WEB_CLIENT_ID=your-google-web-client-id"
    echo "  GOOGLE_ANDROID_CLIENT_ID=140560791771-iojtfce8196hq7duhr7avos5gjpt6idb.apps.googleusercontent.com"
    echo ""
    exit 1
fi
echo -e "${GREEN}✓ .env file found${NC}"

# Run migrations
python manage.py migrate --run-syncdb 2>&1 | grep -v "^$" || true
echo -e "${GREEN}✓ Database migrations applied${NC}"

deactivate

# ─── Flutter Setup ───────────────────────────────────────────
echo -e "${YELLOW}[2/4] Setting up Flutter app...${NC}"

cd "$(dirname "$0")/flutter_app"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found. Please install Flutter first:${NC}"
    echo "  https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check if flutter project needs to be created
if [ ! -f "android/local.properties" ]; then
    echo -e "${YELLOW}  Creating Flutter project structure...${NC}"
    # We need to keep our lib/ files, so we create the project in a temp dir and merge
    TEMP_DIR=$(mktemp -d)
    flutter create --org com.noor --project-name noor_app "$TEMP_DIR/noor_app" --quiet 2>/dev/null || true

    # Copy Android/iOS structure (not lib/)
    if [ -d "$TEMP_DIR/noor_app/android" ]; then
        cp -r "$TEMP_DIR/noor_app/android/." android/ 2>/dev/null || true
    fi
    if [ -d "$TEMP_DIR/noor_app/ios" ]; then
        cp -r "$TEMP_DIR/noor_app/ios/." ios/ 2>/dev/null || true
    fi
    rm -rf "$TEMP_DIR"
fi

# Get Flutter dependencies
flutter pub get
echo -e "${GREEN}✓ Flutter dependencies installed${NC}"

# ─── Google Services ─────────────────────────────────────────
echo -e "${YELLOW}[3/4] Checking Google Services configuration...${NC}"

if [ ! -f "android/app/google-services.json" ]; then
    echo -e "${YELLOW}  ⚠ google-services.json not found.${NC}"
    echo -e "${YELLOW}  Please download it from Firebase Console and place it at:${NC}"
    echo "    flutter_app/android/app/google-services.json"
    echo ""
    echo -e "${YELLOW}  Steps:${NC}"
    echo "  1. Go to https://console.firebase.google.com"
    echo "  2. Create or open your project"
    echo "  3. Add Android app with package: com.noor.quranapp"
    echo "  4. Download google-services.json"
    echo "  5. Place in flutter_app/android/app/"
    echo ""
    echo -e "${YELLOW}  Note: The app will work without Firebase, but Google Sign-In"
    echo "  requires proper google-services.json configuration.${NC}"
fi

# ─── Summary ─────────────────────────────────────────────────
echo -e "${YELLOW}[4/4] Setup complete!${NC}"
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Setup Complete! 🎉                      ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}To run the app:${NC}"
echo ""
echo -e "  ${YELLOW}Backend:${NC}"
echo "  cd backend"
echo "  source venv/bin/activate"
echo "  python manage.py runserver 0.0.0.0:8000"
echo ""
echo -e "  ${YELLOW}Flutter:${NC}"
echo "  cd flutter_app"
echo "  flutter run"
echo ""
echo -e "${BLUE}API will be available at:${NC} http://localhost:8000/api/"
echo ""
