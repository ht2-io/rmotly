# Play Store Submission Checklist

Use this checklist to track your progress in preparing and submitting Rmotly to the Google Play Store.

## Phase 1: Prerequisites

### Developer Account
- [ ] Create Google Play Developer account ($25 one-time fee)
  - URL: https://play.google.com/console
- [ ] Complete identity verification
- [ ] Accept Developer Distribution Agreement
- [ ] Set up payment profile (for future paid features/subscriptions)

### Documentation
- [x] Privacy Policy written (`docs/PRIVACY_POLICY.md`)
- [x] Store Listing content prepared (`docs/STORE_LISTING.md`)
- [ ] Privacy Policy hosted on public URL
  - Options: GitHub Pages, Google Sites, custom domain
  - URL: ______________________________________

### Tools Setup
- [ ] Flutter SDK installed (3.27.4+)
- [ ] Java JDK installed (17+)
- [ ] Android SDK configured
- [ ] keytool available (comes with Java)

## Phase 2: App Configuration

### Application ID & Branding
- [x] Update applicationId to `io.ht2.rmotly` (done in build.gradle)
- [x] Update app name to "Rmotly" (done in AndroidManifest.xml)
- [x] Configure versionCode and versionName (in pubspec.yaml)

### Build Configuration
- [x] ProGuard rules created (proguard-rules.pro)
- [x] Release build configuration added to build.gradle
- [x] Keystore configuration structure in place
- [x] .gitignore updated to exclude keystores

## Phase 3: Signing Setup

### Generate Keystore
- [ ] Generate upload keystore
  ```bash
  cd rmotly_app/android
  keytool -genkey -v -keystore upload-keystore.jks -storetype JKS \
    -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
- [ ] Store password recorded in password manager: _______________
- [ ] Key password recorded in password manager: _______________
- [ ] Keystore details documented:
  - Name: _______________
  - Organization: _______________
  - Location: _______________

### Configure Signing
- [ ] Create `android/key.properties` file:
  ```properties
  storePassword=YOUR_PASSWORD
  keyPassword=YOUR_PASSWORD
  keyAlias=upload
  storeFile=upload-keystore.jks
  ```
- [ ] Backup keystore to secure location (cloud storage): _______________
- [ ] Backup keystore to second location (external drive): _______________
- [ ] Test keystore with:
  ```bash
  keytool -list -v -keystore android/upload-keystore.jks
  ```

## Phase 4: Store Assets

### High-Resolution Icon
- [ ] Create 512x512 PNG icon
- [ ] Icon has transparent background
- [ ] Icon looks good at small sizes
- [ ] File size under 1 MB
- [ ] Saved to: `rmotly_app/assets/store/icon-512.png`

### Feature Graphic
- [ ] Create 1024x500 graphic
- [ ] Includes app icon
- [ ] Includes app name "Rmotly"
- [ ] Includes tagline: "Your Controls. Your Server. Your Privacy."
- [ ] No alpha channel (24-bit PNG or JPEG)
- [ ] File size under 1 MB
- [ ] Saved to: `rmotly_app/assets/store/feature-graphic.png`

### Phone Screenshots
- [ ] Screenshot 1: Dashboard View (1080x1920)
- [ ] Screenshot 2: Control Editor (1080x1920)
- [ ] Screenshot 3: Actions List (1080x1920)
- [ ] Screenshot 4: OpenAPI Import (1080x1920)
- [ ] Screenshot 5: Notification Topics (1080x1920)
- [ ] Screenshot 6: Settings/Theme (1080x1920)
- [ ] Add descriptive captions/overlays (optional but recommended)
- [ ] All screenshots are clear and high-quality
- [ ] No personal/sensitive data visible
- [ ] Saved to: `rmotly_app/assets/store/screenshots/phone/`

### Tablet Screenshots (Optional)
- [ ] 7-inch tablet screenshots (1200x1920)
- [ ] 10-inch tablet screenshots (1600x2560)
- [ ] Saved to: `rmotly_app/assets/store/screenshots/tablet-7/` and `tablet-10/`

### Promo Video (Optional)
- [ ] Video created (30-120 seconds)
- [ ] Uploaded to YouTube
- [ ] YouTube URL: ______________________________________

## Phase 5: Build Release

### Test Build
- [ ] Run build script:
  ```bash
  cd rmotly_app
  ./scripts/build-release.sh
  ```
- [ ] APK builds successfully
- [ ] AAB builds successfully
- [ ] Install APK on test device
- [ ] Test all major features:
  - [ ] Login/Register
  - [ ] Dashboard loads
  - [ ] Create control
  - [ ] Execute action
  - [ ] Receive notification
  - [ ] Settings work
  - [ ] Dark mode works

### Production Build
- [ ] Update version in `pubspec.yaml` (e.g., 1.0.0+1)
- [ ] Build AAB:
  ```bash
  cd rmotly_app
  flutter build appbundle --release
  ```
- [ ] AAB location: `build/app/outputs/bundle/release/app-release.aab`
- [ ] AAB size: _______ MB (should be 15-30 MB)
- [ ] Build logs show no errors
- [ ] Build logs show signing successful

## Phase 6: Play Console Setup

### Create App Entry
- [ ] Go to Google Play Console
- [ ] Click "Create app"
- [ ] Fill in details:
  - App name: Rmotly
  - Language: English (United States)
  - Type: App
  - Free or paid: Free
- [ ] Accept all declarations
- [ ] App created successfully

### App Content
- [ ] Complete Privacy Policy section
  - [ ] Enter public URL for privacy policy
  - [ ] URL accessible: ______________________________________
- [ ] Complete Data Safety section
  - [ ] Answer all questions accurately
  - [ ] Based on `docs/PRIVACY_POLICY.md`
- [ ] Complete Content Rating questionnaire
  - [ ] Submit for rating (should be "Everyone")
  - [ ] Received rating certificate
- [ ] Complete Target Audience section
  - [ ] Select age groups: 13+
  - [ ] Confirm no children-specific features
- [ ] Complete News apps section (if applicable)
  - [ ] Not applicable for Rmotly

### Store Listing
- [ ] Navigate to "Main store listing"
- [ ] Enter App details:
  - [ ] App name: Rmotly
  - [ ] Short description (from STORE_LISTING.md)
  - [ ] Full description (from STORE_LISTING.md)
- [ ] Upload Graphics:
  - [ ] High-res icon (512x512)
  - [ ] Feature graphic (1024x500)
  - [ ] Phone screenshots (2-8 images)
  - [ ] Tablet screenshots (optional)
- [ ] Enter Contact details:
  - [ ] Email: ______________________________________
  - [ ] Phone (optional): ______________________________________
  - [ ] Website (optional): ______________________________________
- [ ] Select Category:
  - [ ] Primary: Tools
- [ ] Add Tags (optional):
  - remote control, automation, smart home, self-hosted
- [ ] Save all changes

### Store Settings
- [ ] Configure App access
  - [ ] All features available without restrictions
- [ ] Configure Ads
  - [ ] No ads (for now)
- [ ] Configure App content
  - [ ] Review all sections for green checkmarks

## Phase 7: Release Setup

### Production Track
- [ ] Navigate to "Production" track
- [ ] Click "Create new release"
- [ ] Choose "Use Google Play App Signing" (recommended)
- [ ] Upload AAB file
  - [ ] Upload successful
  - [ ] File size: _______ MB
- [ ] Enter Release name: 1.0.0
- [ ] Enter Release notes:
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
- [ ] Save as draft

### Pre-Submission Review
- [ ] All App Content sections complete (green checkmarks)
- [ ] Store listing complete with all assets
- [ ] Privacy policy URL working
- [ ] Release ready for review
- [ ] No errors or warnings in console

## Phase 8: Submit for Review

### Final Checks
- [ ] Test app one more time on physical device
- [ ] Verify all permissions in AndroidManifest.xml are necessary
- [ ] Verify app doesn't crash or hang
- [ ] Verify all screenshots match current app version
- [ ] Verify privacy policy is up to date
- [ ] Double-check version number matches build

### Submit
- [ ] Navigate to Production release draft
- [ ] Click "Review release"
- [ ] Review summary
- [ ] Click "Start rollout to Production"
- [ ] Confirm rollout
- [ ] Note submission date: ______________________________________
- [ ] Save confirmation/tracking number (if provided)

### Post-Submission
- [ ] Monitor email for Google updates
- [ ] Check Play Console daily for status changes
- [ ] Expected review time: 3-7 days

## Phase 9: After Approval

### Verification
- [ ] Received approval email
- [ ] Approval date: ______________________________________
- [ ] Search "Rmotly" in Play Store
- [ ] App appears in search results
- [ ] Install app from Play Store on test device
- [ ] Verify all features work correctly

### Promotion
- [ ] Get Play Store URL: ______________________________________
- [ ] Add Play Store badge to README.md
- [ ] Update TASKS.md to mark task complete
- [ ] Share announcement on social media
- [ ] Post in relevant communities (r/selfhosted, r/androidapps)
- [ ] Update website/documentation with Play Store link

### Monitoring
- [ ] Set up alerts for new reviews
- [ ] Respond to user reviews promptly
- [ ] Monitor crash reports in Play Console
- [ ] Track download statistics

## Common Issues & Solutions

### Build Issues
- **Keystore not found**: Check `key.properties` path is correct
- **Wrong password**: Verify passwords in password manager
- **Build fails**: Run `flutter clean` and try again

### Upload Issues
- **Version code exists**: Increment version in `pubspec.yaml`
- **Package name taken**: Very unlikely, but would need to change applicationId

### Review Rejections
- **Privacy policy**: Ensure URL is accessible and matches data collection
- **Content rating**: Re-review questionnaire answers
- **Misleading content**: Ensure screenshots match functionality
- **Permissions**: Only request necessary permissions

## Emergency Contacts

- **Google Play Support**: https://support.google.com/googleplay/android-developer
- **Project Repository**: https://github.com/ht2-io/rmotly
- **Documentation**: See `docs/PLAY_STORE_SUBMISSION.md`

## Notes

Use this space for notes, tracking numbers, or important dates:

```
[Date] - [Event/Note]




```

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Status**: ☐ Not Started | ☐ In Progress | ☐ Complete
