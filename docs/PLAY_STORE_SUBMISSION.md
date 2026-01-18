# Google Play Store Submission Guide

This guide provides step-by-step instructions for submitting the Rmotly Android app to the Google Play Store.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Generate Signing Key](#generate-signing-key)
3. [Configure Signing](#configure-signing)
4. [Build Release Bundle](#build-release-bundle)
5. [Create Store Assets](#create-store-assets)
6. [Set Up Play Console](#set-up-play-console)
7. [Submit for Review](#submit-for-review)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

### Developer Account

- [ ] Google Play Developer account ($25 one-time registration fee)
  - Sign up at [play.google.com/console](https://play.google.com/console)
  - Complete identity verification
  - Accept Developer Distribution Agreement

### Documentation

- [x] Privacy Policy (`docs/PRIVACY_POLICY.md`)
- [x] Store Listing Content (`docs/STORE_LISTING.md`)
- [ ] Privacy Policy hosted on public URL (required)

### Tools Required

- Flutter SDK 3.27.4 or higher
- Java JDK 17 or higher
- Android SDK (installed with Flutter)

## Generate Signing Key

### Step 1: Generate Upload Keystore

```bash
cd rmotly_app/android

# Generate a new keystore
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

**Important**: Answer all prompts carefully and **save your passwords securely**!

- Store Password: Use a strong password (min 6 characters)
- Key Password: Can be the same as store password
- First and Last Name: Your name or organization name
- Organizational Unit: Optional (e.g., "Development")
- Organization: Your organization name (e.g., "HT2 IO")
- City/Locality: Your city
- State/Province: Your state
- Country Code: Two-letter country code (e.g., "US")

### Step 2: Create key.properties

Create `rmotly_app/android/key.properties` (this file is gitignored):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

Replace `YOUR_STORE_PASSWORD` and `YOUR_KEY_PASSWORD` with your actual passwords.

### Step 3: Secure Your Keys

**CRITICAL**: Store your keystore and passwords securely:

- [ ] Backup keystore file to secure location (encrypted cloud storage, password manager)
- [ ] Save passwords in password manager (1Password, LastPass, Bitwarden)
- [ ] Never commit keystore or key.properties to version control
- [ ] Document recovery process

**Warning**: If you lose your keystore, you cannot update your app! You'll need to publish a new app with a different package name.

## Configure Signing

The signing configuration is already set up in `android/app/build.gradle`. Verify:

1. Check `applicationId`: Should be `io.ht2.rmotly`
2. Check `versionCode` and `versionName` in `pubspec.yaml`
3. Verify keystore configuration loads from `key.properties`

## Build Release Bundle

### For Google Play Store (AAB - Required)

```bash
cd rmotly_app

# Get dependencies
flutter pub get

# Build Android App Bundle
flutter build appbundle --release

# Output location
# build/app/outputs/bundle/release/app-release.aab
```

### For Testing (APK - Optional)

```bash
cd rmotly_app

# Build release APK
flutter build apk --release

# Output location
# build/app/outputs/flutter-apk/app-release.apk
```

### Verify Build

```bash
# Check file exists
ls -lh build/app/outputs/bundle/release/app-release.aab

# Expected size: 15-30 MB for AAB
```

## Create Store Assets

### Required Assets Checklist

- [ ] **High-res Icon**: 512x512 PNG with transparency
- [ ] **Feature Graphic**: 1024x500 JPEG or PNG
- [ ] **Screenshots**: Minimum 2, maximum 8 per device type
  - [ ] Phone screenshots (required)
  - [ ] 7-inch tablet screenshots (optional)
  - [ ] 10-inch tablet screenshots (optional)

### Screenshot Specifications

**Phone Screenshots**
- Format: JPEG or PNG (24-bit, no alpha)
- Minimum dimensions: 320px
- Maximum dimensions: 3840px
- Aspect ratio: Between 16:9 and 9:16
- Recommended: 1080 x 1920 (9:16)

**Tablet Screenshots (Optional)**
- 7-inch: 1200 x 1920
- 10-inch: 1600 x 2560

### Taking Screenshots

#### Option 1: Using Emulator

```bash
# Start emulator
flutter emulators --launch <emulator_id>

# Run app
cd rmotly_app
flutter run

# Take screenshot from Android Studio
# Tools → Device Manager → Camera icon
```

#### Option 2: Using Real Device

```bash
# Enable USB debugging on device
# Connect via USB

cd rmotly_app
flutter run

# Take screenshot
adb exec-out screencap -p > screenshot.png
```

#### Option 3: Using Flutter DevTools

```bash
flutter run
# Press 'p' to take screenshot
# Or use Flutter DevTools → Inspector → Export
```

### Screenshot Content Guidelines

Based on `docs/STORE_LISTING.md`, create screenshots showing:

1. **Dashboard View** - Main control grid with various control types
2. **Control Editor** - Configuration screen
3. **Actions List** - HTTP actions management
4. **OpenAPI Import** - API integration feature
5. **Notification Topics** - Webhook notifications
6. **Settings** - Theme and preferences

### Creating Feature Graphic

The feature graphic (1024x500) should include:
- App icon or logo
- App name: "Rmotly"
- Tagline: "Your Controls. Your Server. Your Privacy."
- Background with brand colors

Tools:
- Canva (free templates)
- Figma
- GIMP
- Adobe Photoshop

### Creating High-res Icon

- Size: 512x512 pixels
- Format: 32-bit PNG with alpha
- Design: Match your app's launcher icon
- Should be recognizable at small sizes

## Set Up Play Console

### 1. Create App Entry

1. Go to [Google Play Console](https://play.google.com/console)
2. Click **Create app**
3. Fill in details:
   - **App name**: Rmotly
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free
4. Accept declarations (complete later)
5. Click **Create app**

### 2. Set Up App Content

#### Privacy Policy

1. Navigate to **App content** → **Privacy policy**
2. Host your privacy policy on a public URL:
   - Option A: GitHub Pages (https://ht2-io.github.io/rmotly/privacy-policy.html)
   - Option B: Your domain (https://rmotly.io/privacy)
   - Option C: Google Sites (free)
3. Enter the URL in Play Console
4. Save

**Quick Hosting with GitHub Pages:**

```bash
# In your repo
mkdir docs/web
cp docs/PRIVACY_POLICY.md docs/web/privacy-policy.html
# Convert markdown to HTML (or use pandoc)

# Enable GitHub Pages in repo settings
# Settings → Pages → Source: docs/web
```

#### Data Safety

1. Navigate to **App content** → **Data safety**
2. Complete questionnaire based on `docs/PRIVACY_POLICY.md`:
   - **Does your app collect data?**: Yes (email, user-created content)
   - **Does your app share data?**: No
   - **Is data encrypted in transit?**: Yes
   - **Can users request data deletion?**: Yes
   - **Data types collected**:
     - Email address (required for authentication)
     - User-generated content (controls, actions, topics)
3. Save

#### Content Rating

1. Navigate to **App content** → **Content rating**
2. Click **Start questionnaire**
3. Select **IARC questionnaire**
4. Answer questions (app should be rated "Everyone"):
   - No violence, sexual content, language, controlled substances
   - No user-generated content shared publicly
   - No gambling, horror themes
5. Submit for rating

#### Target Audience

1. Navigate to **App content** → **Target audience**
2. Select age groups:
   - **13 and older** (recommended)
3. No children's content
4. Save

#### App Category

1. Navigate to **Store presence** → **Main store listing**
2. Select:
   - **Category**: Tools
   - **Tags**: remote control, automation, smart home, self-hosted

### 3. Complete Store Listing

1. Navigate to **Store presence** → **Main store listing**

2. **App details**:
   - App name: `Rmotly`
   - Short description: Use content from `docs/STORE_LISTING.md` (80 chars max)
   - Full description: Use content from `docs/STORE_LISTING.md` (4000 chars max)

3. **Graphics**:
   - Upload high-res icon (512x512)
   - Upload feature graphic (1024x500)
   - Upload phone screenshots (2-8 images)
   - Optional: Upload tablet screenshots

4. **Contact details**:
   - Email: Your support email
   - Optional: Phone number, website

5. Save

### 4. Set Up Release

#### Production Track

1. Navigate to **Release** → **Production**
2. Click **Create new release**

3. **App signing**:
   - Choose **Google Play App Signing**
   - Upload your AAB file
   - Google will manage signing keys

4. **Release details**:
   - Release name: `1.0.0` (from pubspec.yaml)
   - Release notes:
     ```
     Initial release of Rmotly - Self-hosted remote control and notification app.
     
     Features:
     • Custom dashboard controls (buttons, toggles, sliders)
     • HTTP action integration
     • OpenAPI/Swagger import
     • Webhook notifications
     • Privacy-first, self-hosted design
     • Dark mode support
     ```

5. **Review and rollout**:
   - Save as draft
   - Review all sections for completeness

## Submit for Review

### Pre-submission Checklist

Before submitting, verify:

- [ ] All **App content** sections completed (green checkmarks)
- [ ] **Store listing** complete with all required assets
- [ ] **Privacy policy** URL accessible publicly
- [ ] **AAB file** uploaded to release
- [ ] **Release notes** added
- [ ] **App version** matches pubspec.yaml (1.0.0)
- [ ] Tested app on at least one physical device
- [ ] All required permissions declared in AndroidManifest.xml

### Submit

1. Navigate to **Release** → **Production** → your draft release
2. Review summary for any warnings or errors
3. Click **Review release**
4. Click **Start rollout to Production**
5. Confirm rollout

### Review Timeline

- **Initial review**: 3-7 days typically
- **Status updates**: Check Play Console for updates
- **Email notifications**: Monitor email for Google's responses

### Common Rejection Reasons

1. **Privacy policy issues**:
   - Policy not accessible
   - Missing required disclosures
   - Doesn't match actual data collection

2. **Content rating discrepancies**:
   - App content doesn't match questionnaire answers

3. **Misleading store listing**:
   - Screenshots don't match app functionality
   - Description exaggerates features

4. **Permissions issues**:
   - Requesting unnecessary permissions
   - Not declaring all used permissions

5. **App crashes or doesn't function**:
   - Test thoroughly before submitting!

## Troubleshooting

### Build Issues

**Problem**: `Keystore file not found`
```bash
# Solution: Check key.properties path
cat android/key.properties
# Ensure storeFile path is correct (relative to android/ directory)
```

**Problem**: `Could not read key from keystore`
```bash
# Solution: Verify password is correct
keytool -list -v -keystore android/upload-keystore.jks
```

**Problem**: `AAPT: error: resource android:attr/lStar not found`
```bash
# Solution: Update compileSdkVersion in build.gradle
# Ensure compileSdk = 34 or higher
```

### Upload Issues

**Problem**: `Version code already exists`
```bash
# Solution: Increment versionCode in pubspec.yaml
# Example: version: 1.0.0+2 (increment the +2)
```

**Problem**: `Package name already exists`
```bash
# Solution: Change applicationId in android/app/build.gradle
# Must be unique across all Play Store apps
```

### Review Issues

**Problem**: App rejected for policy violation
```text
Solution: Read rejection email carefully
- Fix specific issues mentioned
- Update app if needed
- Resubmit with explanation of changes
```

**Problem**: Long review time (>7 days)
```text
Solution: Be patient
- Check status in Play Console
- Don't resubmit unless asked
- Contact support only after 7+ days
```

## Post-Submission

### After Approval

1. **Test the published app**:
   - Search for "Rmotly" in Play Store
   - Install on test device
   - Verify functionality

2. **Promote your app**:
   - Share Play Store link
   - Add badge to README.md
   - Announce on social media

3. **Monitor reviews**:
   - Respond to user reviews
   - Fix reported issues quickly

### Future Updates

To release updates:

1. Increment version in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # version_name+version_code
   ```

2. Build new AAB:
   ```bash
   flutter build appbundle --release
   ```

3. Create new release in Play Console:
   - Upload new AAB
   - Add release notes
   - Roll out to Production

### Rollout Options

- **Staged rollout**: Release to percentage of users first
  - Start with 5-10%
  - Monitor crash reports
  - Gradually increase to 100%

- **Internal testing**: Test with internal team first
- **Closed testing**: Test with selected users
- **Open testing**: Public beta before production

## Additional Resources

- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Launch Checklist](https://developer.android.com/distribute/best-practices/launch/launch-checklist)
- [Play Console Documentation](https://developer.android.com/distribute/console)
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)

## Security Notes

### Keystore Security

⚠️ **CRITICAL**: Your upload keystore is the key to your app's identity.

**Best Practices**:
1. Store keystore file in multiple secure locations
2. Use strong, unique passwords
3. Document recovery procedures
4. Use Google Play App Signing (recommended)
5. Never share keystore file with anyone
6. Keep offline backup on encrypted drive

**If Keystore is Lost**:
- Cannot update existing app
- Must publish new app with different package name
- Lose all reviews, ratings, and user base
- **Prevention is critical!**

### Play App Signing

Google Play App Signing (recommended):
- Google stores your app signing key
- You upload with upload key
- Google re-signs with app signing key
- Can reset upload key if lost
- **Protects against key loss**

To enable: Select "Use Google Play App Signing" during first release.

## Checklist Summary

### One-Time Setup
- [ ] Google Play Developer account ($25)
- [ ] Generate upload keystore
- [ ] Configure signing in build.gradle
- [ ] Create key.properties file
- [ ] Backup keystore securely

### For Each Release
- [ ] Update version in pubspec.yaml
- [ ] Build AAB: `flutter build appbundle --release`
- [ ] Test APK on physical device
- [ ] Create release in Play Console
- [ ] Upload AAB file
- [ ] Add release notes
- [ ] Review and submit

### Store Listing (One-Time)
- [ ] Create all required assets
- [ ] Complete app content sections
- [ ] Set up privacy policy URL
- [ ] Complete store listing
- [ ] Submit for content rating

---

**Need Help?** Open an issue on the [Rmotly GitHub repository](https://github.com/ht2-io/rmotly).
