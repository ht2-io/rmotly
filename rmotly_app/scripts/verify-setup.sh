#!/bin/bash
# Verify Play Store submission readiness

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=================================================="
echo "  Rmotly - Play Store Readiness Check"
echo "=================================================="
echo ""

ERRORS=0
WARNINGS=0

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}✗ Not in rmotly_app directory${NC}"
    echo "  Please run this script from rmotly_app directory"
    exit 1
fi

echo -e "${BLUE}Checking prerequisites...${NC}"
echo ""

# Check Flutter
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -1)
    echo -e "${GREEN}✓ Flutter installed${NC}: $FLUTTER_VERSION"
else
    echo -e "${RED}✗ Flutter not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check Java
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -1)
    echo -e "${GREEN}✓ Java installed${NC}: $JAVA_VERSION"
else
    echo -e "${RED}✗ Java not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check keytool
if command -v keytool &> /dev/null; then
    echo -e "${GREEN}✓ keytool available${NC}"
else
    echo -e "${YELLOW}⚠ keytool not found${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo -e "${BLUE}Checking configuration files...${NC}"
echo ""

# Check build.gradle
if grep -q "io.ht2.rmotly" android/app/build.gradle; then
    echo -e "${GREEN}✓ Application ID configured${NC}: io.ht2.rmotly"
else
    echo -e "${RED}✗ Application ID not set${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check ProGuard rules
if [ -f "android/app/proguard-rules.pro" ]; then
    echo -e "${GREEN}✓ ProGuard rules file exists${NC}"
else
    echo -e "${RED}✗ ProGuard rules missing${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check AndroidManifest
if grep -q 'android:label="Rmotly"' android/app/src/main/AndroidManifest.xml; then
    echo -e "${GREEN}✓ App name configured${NC}: Rmotly"
else
    echo -e "${YELLOW}⚠ App name not updated${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo -e "${BLUE}Checking signing configuration...${NC}"
echo ""

# Check for keystore
if [ -f "android/key.properties" ]; then
    echo -e "${GREEN}✓ key.properties exists${NC}"
    
    # Check keystore file
    KEYSTORE_FILE=$(grep "storeFile=" android/key.properties | cut -d= -f2)
    if [ -f "android/$KEYSTORE_FILE" ]; then
        echo -e "${GREEN}✓ Keystore file exists${NC}: $KEYSTORE_FILE"
    else
        echo -e "${RED}✗ Keystore file not found${NC}: $KEYSTORE_FILE"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ key.properties not found${NC}"
    echo "  This is needed for release builds."
    echo "  See docs/PLAY_STORE_SUBMISSION.md for setup instructions."
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo -e "${BLUE}Checking documentation...${NC}"
echo ""

DOCS_FOUND=0
DOCS_EXPECTED=5

[ -f "../docs/PLAY_STORE_SUBMISSION.md" ] && DOCS_FOUND=$((DOCS_FOUND + 1))
[ -f "../docs/STORE_ASSETS_GUIDE.md" ] && DOCS_FOUND=$((DOCS_FOUND + 1))
[ -f "../docs/PLAY_STORE_CHECKLIST.md" ] && DOCS_FOUND=$((DOCS_FOUND + 1))
[ -f "../docs/PLAY_STORE_QUICK_REF.md" ] && DOCS_FOUND=$((DOCS_FOUND + 1))
[ -f "../docs/STORE_LISTING.md" ] && DOCS_FOUND=$((DOCS_FOUND + 1))

if [ $DOCS_FOUND -eq $DOCS_EXPECTED ]; then
    echo -e "${GREEN}✓ All documentation files present${NC}: $DOCS_FOUND/$DOCS_EXPECTED"
else
    echo -e "${YELLOW}⚠ Some documentation missing${NC}: $DOCS_FOUND/$DOCS_EXPECTED"
    WARNINGS=$((WARNINGS + 1))
fi

# Check build script
if [ -f "scripts/build-release.sh" ]; then
    if [ -x "scripts/build-release.sh" ]; then
        echo -e "${GREEN}✓ Build script exists and is executable${NC}"
    else
        echo -e "${YELLOW}⚠ Build script not executable${NC}"
        echo "  Run: chmod +x scripts/build-release.sh"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗ Build script missing${NC}"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo -e "${BLUE}Checking dependencies...${NC}"
echo ""

# Check if pub get has been run
if [ -f "pubspec.lock" ]; then
    echo -e "${GREEN}✓ Dependencies resolved${NC}"
else
    echo -e "${YELLOW}⚠ Dependencies not resolved${NC}"
    echo "  Run: flutter pub get"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "=================================================="
echo "  Summary"
echo "=================================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Your setup is ready for Play Store submission."
    echo ""
    if [ ! -f "android/key.properties" ]; then
        echo "Next steps:"
        echo "  1. Generate keystore (see docs/PLAY_STORE_SUBMISSION.md)"
        echo "  2. Create store assets (see docs/STORE_ASSETS_GUIDE.md)"
        echo "  3. Build release: ./scripts/build-release.sh"
        echo "  4. Submit to Play Console"
    else
        echo "Next steps:"
        echo "  1. Create store assets (see docs/STORE_ASSETS_GUIDE.md)"
        echo "  2. Build release: ./scripts/build-release.sh"
        echo "  3. Submit to Play Console"
    fi
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s)${NC}"
    echo ""
    echo "Your setup is mostly ready, but please review the warnings above."
else
    echo -e "${RED}✗ $ERRORS error(s), $WARNINGS warning(s)${NC}"
    echo ""
    echo "Please fix the errors above before proceeding."
fi

echo ""
echo "Documentation:"
echo "  • Quick Start: docs/PLAY_STORE_QUICK_REF.md"
echo "  • Complete Guide: docs/PLAY_STORE_SUBMISSION.md"
echo "  • Asset Guide: docs/STORE_ASSETS_GUIDE.md"
echo "  • Checklist: docs/PLAY_STORE_CHECKLIST.md"
echo ""
echo "=================================================="

exit $ERRORS
