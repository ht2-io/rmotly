# Play Store Submission - Quick Reference

This document provides a quick overview of the Google Play Store submission process for Rmotly. For detailed instructions, see the full guides.

## 📚 Documentation

| Document | Purpose | Size |
|----------|---------|------|
| [PLAY_STORE_SUBMISSION.md](PLAY_STORE_SUBMISSION.md) | Complete submission guide | 15KB |
| [STORE_ASSETS_GUIDE.md](STORE_ASSETS_GUIDE.md) | Asset creation instructions | 10KB |
| [PLAY_STORE_CHECKLIST.md](PLAY_STORE_CHECKLIST.md) | Interactive checklist | 10KB |
| [STORE_LISTING.md](STORE_LISTING.md) | App descriptions & metadata | 8KB |
| [PRIVACY_POLICY.md](PRIVACY_POLICY.md) | Privacy policy text | 3KB |

## 🚀 Quick Start (TL;DR)

### Prerequisites
1. **Google Play Developer Account** ($25 one-time)
   - Sign up: https://play.google.com/console
2. **Signing Key** (Generate with provided script)
3. **Store Assets** (Create using guides)

### Steps

```bash
# 1. Generate keystore (one-time)
cd rmotly_app/android
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. Create key.properties
cat > key.properties << EOF
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
EOF

# 3. Build release
cd ..
./scripts/build-release.sh

# 4. Upload to Play Console
# - Go to play.google.com/console
# - Create app
# - Upload build/app/outputs/bundle/release/app-release.aab
# - Complete store listing
# - Submit for review
```

## 📝 What's Prepared

### ✅ App Configuration
- Application ID: `io.ht2.rmotly`
- App name: "Rmotly"
- Release signing configured
- ProGuard rules added
- Build scripts ready

### ✅ Documentation
- Complete submission guide (14KB)
- Asset creation guide (10KB)
- Interactive checklist (10KB)
- Privacy policy written
- Store listing content prepared

### ✅ CI/CD
- AAB build in release workflow
- Automated GitHub releases
- Docker image publishing

### ⏭️ Developer Actions Required

1. **One-Time Setup** (1-2 hours)
   - [ ] Register Google Play Developer account
   - [ ] Generate upload keystore
   - [ ] Backup keystore securely

2. **Create Assets** (4-8 hours)
   - [ ] High-res icon (512x512 PNG)
   - [ ] Feature graphic (1024x500)
   - [ ] 6-8 screenshots (1080x1920)
   - [ ] Host privacy policy on public URL

3. **Submit** (2-3 hours)
   - [ ] Set up Play Console
   - [ ] Upload AAB
   - [ ] Complete store listing
   - [ ] Submit for review

**Total Time**: 8-14 hours + 3-7 days Google review

## 🎨 Required Assets

| Asset | Size | Format | Status |
|-------|------|--------|--------|
| High-res icon | 512x512 | PNG (32-bit) | ⏭️ To create |
| Feature graphic | 1024x500 | PNG/JPEG | ⏭️ To create |
| Screenshots | 1080x1920 | PNG/JPEG | ⏭️ To create |
| Privacy policy | N/A | Public URL | ⏭️ To host |

### Screenshot Plan
1. Dashboard View - Main control grid
2. Control Editor - Configuration screen
3. Actions List - HTTP actions
4. OpenAPI Import - API integration
5. Notification Topics - Webhooks
6. Settings - Theme & preferences

## 🔧 Build Commands

```bash
# Build AAB (for Play Store)
cd rmotly_app
flutter build appbundle --release

# Build APK (for testing)
flutter build apk --release

# Or use script (recommended)
./scripts/build-release.sh
```

## 📱 App Details

```yaml
Package Name: io.ht2.rmotly
App Name: Rmotly
Version: 1.0.0+1 (from pubspec.yaml)
Category: Tools
Rating: Everyone
Price: Free

Short Description:
  "Self-hosted remote control dashboard. Trigger APIs, receive notifications."

Full Description:
  See docs/STORE_LISTING.md for complete text
```

## 🔐 Security Checklist

- [ ] Keystore generated with strong password
- [ ] Keystore backed up to secure location (2+ places)
- [ ] key.properties added to .gitignore (already done)
- [ ] Passwords stored in password manager
- [ ] Never commit keystore to version control

**⚠️ CRITICAL**: Losing your keystore means you can't update your app!

## 📋 Submission Checklist (Abbreviated)

See [PLAY_STORE_CHECKLIST.md](PLAY_STORE_CHECKLIST.md) for full checklist.

### Phase 1: Setup
- [ ] Developer account registered
- [ ] Keystore generated and backed up
- [ ] key.properties configured

### Phase 2: Assets
- [ ] Icon created (512x512)
- [ ] Feature graphic created (1024x500)
- [ ] Screenshots taken (6-8 images)
- [ ] Privacy policy hosted

### Phase 3: Build
- [ ] Build successful
- [ ] APK tested on device
- [ ] AAB ready for upload

### Phase 4: Play Console
- [ ] App created in console
- [ ] All content sections completed
- [ ] Store listing filled
- [ ] Assets uploaded

### Phase 5: Submit
- [ ] Release created
- [ ] AAB uploaded
- [ ] Release notes added
- [ ] Submitted for review

### Phase 6: Post-Approval
- [ ] App tested from Play Store
- [ ] Play Store link shared
- [ ] README updated with badge

## 🆘 Need Help?

### Quick Links
- [Full Submission Guide](PLAY_STORE_SUBMISSION.md)
- [Asset Creation Guide](STORE_ASSETS_GUIDE.md)
- [Detailed Checklist](PLAY_STORE_CHECKLIST.md)
- [Google Play Console](https://play.google.com/console)
- [Google Support](https://support.google.com/googleplay/android-developer)

### Common Issues

**Build fails with signing error**
- Check key.properties path and passwords
- Verify keystore exists at specified location

**Upload rejected**
- Increment versionCode in pubspec.yaml
- Ensure AAB is signed (not debug build)

**Review rejection**
- Read rejection email carefully
- Check privacy policy is accessible
- Verify screenshots match app functionality

## 📊 Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| App configuration | Done | ✅ |
| Documentation | Done | ✅ |
| Developer setup | 1-2 hours | ⏭️ |
| Asset creation | 4-8 hours | ⏭️ |
| Play Console | 2-3 hours | ⏭️ |
| Google review | 3-7 days | ⏭️ |
| **Total** | **~2 weeks** | **In Progress** |

## 📖 Next Steps

1. **Read**: [PLAY_STORE_SUBMISSION.md](PLAY_STORE_SUBMISSION.md) (15 min)
2. **Register**: Google Play Developer account
3. **Generate**: Upload keystore (5 min)
4. **Create**: Store assets (4-8 hours)
5. **Build**: AAB with `./scripts/build-release.sh`
6. **Upload**: To Play Console
7. **Submit**: For review

**Good luck!** 🚀

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Author**: GitHub Copilot
