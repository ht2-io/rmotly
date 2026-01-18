#!/bin/bash
# Build Android App Bundle for Google Play Store submission

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=================================================="
echo "  Rmotly - Play Store Release Build"
echo "=================================================="
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: pubspec.yaml not found. Please run this script from rmotly_app directory.${NC}"
    exit 1
fi

# Check for key.properties
if [ ! -f "android/key.properties" ]; then
    echo -e "${YELLOW}Warning: android/key.properties not found!${NC}"
    echo ""
    echo "You need to create a signing key first. See docs/PLAY_STORE_SUBMISSION.md"
    echo ""
    echo "Quick setup:"
    echo "  1. Generate keystore:"
    echo "     keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload"
    echo ""
    echo "  2. Create android/key.properties:"
    echo "     storePassword=<password>"
    echo "     keyPassword=<password>"
    echo "     keyAlias=upload"
    echo "     storeFile=upload-keystore.jks"
    echo ""
    read -p "Do you want to continue without signing? (APK only, not for Play Store) [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    UNSIGNED=true
else
    UNSIGNED=false
fi

# Get current version
VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
echo -e "${GREEN}Building version: ${VERSION}${NC}"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo ""

# Build App Bundle (for Play Store)
if [ "$UNSIGNED" = false ]; then
    echo "🏗️  Building Android App Bundle (AAB)..."
    flutter build appbundle --release
    
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        AAB_SIZE=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
        echo -e "${GREEN}✅ App Bundle built successfully!${NC}"
        echo "   Location: build/app/outputs/bundle/release/app-release.aab"
        echo "   Size: ${AAB_SIZE}"
        echo ""
    else
        echo -e "${RED}❌ App Bundle build failed!${NC}"
        exit 1
    fi
fi

# Build APK (for testing)
echo "🏗️  Building Android APK (for testing)..."
if [ "$UNSIGNED" = false ]; then
    flutter build apk --release
else
    flutter build apk --debug
fi

if [ "$UNSIGNED" = false ]; then
    APK_FILE="build/app/outputs/flutter-apk/app-release.apk"
else
    APK_FILE="build/app/outputs/flutter-apk/app-debug.apk"
fi

if [ -f "$APK_FILE" ]; then
    APK_SIZE=$(du -h "$APK_FILE" | cut -f1)
    echo -e "${GREEN}✅ APK built successfully!${NC}"
    echo "   Location: ${APK_FILE}"
    echo "   Size: ${APK_SIZE}"
    echo ""
else
    echo -e "${RED}❌ APK build failed!${NC}"
    exit 1
fi

# Summary
echo "=================================================="
echo "  Build Summary"
echo "=================================================="
echo ""
echo "Version: ${VERSION}"
echo ""

if [ "$UNSIGNED" = false ]; then
    echo "📦 App Bundle (for Play Store):"
    echo "   build/app/outputs/bundle/release/app-release.aab"
    echo ""
fi

echo "📱 APK (for testing):"
echo "   ${APK_FILE}"
echo ""

if [ "$UNSIGNED" = false ]; then
    echo -e "${GREEN}✅ Ready for Play Store submission!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Test the APK on a real device"
    echo "  2. Prepare store assets (see docs/PLAY_STORE_SUBMISSION.md)"
    echo "  3. Upload AAB to Play Console"
    echo "  4. Complete store listing"
    echo "  5. Submit for review"
else
    echo -e "${YELLOW}⚠️  Unsigned build. Not suitable for Play Store.${NC}"
    echo ""
    echo "To build for Play Store:"
    echo "  1. Set up signing key (see docs/PLAY_STORE_SUBMISSION.md)"
    echo "  2. Run this script again"
fi
echo ""
echo "=================================================="
