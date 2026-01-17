# App Store Listing

## Google Play Store

### App Name
```
Rmotly - Remote Control & Notifications
```

### Short Description (80 characters)
```
Self-hosted remote control dashboard. Trigger APIs, receive notifications.
```

### Full Description (4000 characters)

```
Rmotly is a privacy-first, self-hosted remote control and notification app that puts you in complete control of your smart home, IoT devices, and custom automations.

KEY FEATURES

Dashboard Controls
Create custom controls that trigger HTTP actions:
- Buttons for instant triggers
- Toggles for on/off states
- Sliders for range values
- Text inputs for custom data
- Dropdowns for selections

OpenAPI Integration
Import API endpoints directly from OpenAPI/Swagger specifications. Connect to any documented API with just a URL.

Webhook Notifications
Receive notifications from any service that can send webhooks:
- Home Assistant automations
- IFTTT triggers
- Custom scripts and services
- Server monitoring alerts

PRIVACY FIRST

Unlike other smart home apps, Rmotly is completely self-hosted:
- Your data never leaves your server
- No cloud accounts required
- No telemetry or analytics
- No Firebase or Google services
- Full open source code

SELF-HOSTED PUSH NOTIFICATIONS

Rmotly uses UnifiedPush and ntfy for notifications, giving you:
- No Google Play Services required
- Works on degoogled phones
- Complete privacy
- Self-hosted notification server

TECHNICAL DETAILS

Built with modern technologies:
- Flutter for native performance
- Serverpod Dart backend
- PostgreSQL database
- Redis caching
- WebSocket real-time updates

IDEAL FOR

- Smart home enthusiasts
- Privacy-conscious users
- Developers and makers
- Home automation hobbyists
- Anyone wanting control over their data

REQUIREMENTS

- Self-hosted Serverpod backend (see docs)
- Docker for easy deployment
- Optional: ntfy server for push notifications

OPEN SOURCE

Rmotly is fully open source. Inspect the code, contribute features, or host your own instance. Links in developer contact.

Get started today and take control of your smart home the private way!
```

### Category
```
Tools
```

### Tags
```
remote control, smart home, automation, self-hosted, privacy, iot, notifications, dashboard, api
```

### Content Rating
```
Everyone
```

---

## Screenshots Guide

### Required Screenshots

1. **Dashboard View** (Feature 1)
   - Show the main control grid
   - Include various control types (button, toggle, slider)
   - Caption: "Customizable dashboard with drag-and-drop controls"

2. **Control Editor** (Feature 2)
   - Show control configuration screen
   - Display type selection and options
   - Caption: "Create buttons, toggles, sliders, and more"

3. **Actions List** (Feature 3)
   - Show list of configured actions
   - Include test buttons
   - Caption: "Define HTTP actions for any API"

4. **OpenAPI Import** (Feature 4)
   - Show operation browser
   - Display parsed API endpoints
   - Caption: "Import APIs from OpenAPI specifications"

5. **Notification Topics** (Feature 5)
   - Show topics list with webhook URLs
   - Display enable/disable toggles
   - Caption: "Receive notifications via webhooks"

6. **Settings** (Feature 6)
   - Show settings screen with theme options
   - Display push notification settings
   - Caption: "Dark mode and notification preferences"

### Screenshot Specifications

**Phone**
- Format: JPEG or PNG
- Resolution: 1080 x 1920 (9:16 aspect ratio)
- Max file size: 8 MB

**Tablet (7-inch)**
- Resolution: 1200 x 1920

**Tablet (10-inch)**
- Resolution: 1600 x 2560

### Feature Graphic
- Size: 1024 x 500
- Content: App icon with tagline "Your Controls. Your Server. Your Privacy."

---

## Apple App Store (Future)

### App Name
```
Rmotly
```

### Subtitle (30 characters)
```
Self-Hosted Remote Control
```

### Promotional Text (170 characters)
```
Create custom dashboards, trigger APIs, and receive notifications - all on your own server. Privacy-first automation without the cloud.
```

### Keywords (100 characters)
```
remote,control,smart,home,automation,dashboard,api,webhook,notification,self-hosted,privacy
```

### App Store Category
```
Primary: Utilities
Secondary: Productivity
```

---

## Store Assets Checklist

### Required

- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500)
- [ ] Screenshots (min 2, max 8)
- [ ] Short description
- [ ] Full description
- [ ] Privacy policy URL

### Recommended

- [ ] Promo video (30-120 seconds)
- [ ] What's new text for updates
- [ ] Localized descriptions

---

## Build Commands

### Android APK
```bash
cd rmotly_app
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
cd rmotly_app
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (requires Mac)
```bash
cd rmotly_app
flutter build ios --release
```

---

## Signing

### Android

1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -storetype JKS \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `key.properties`:
   ```properties
   storePassword=your-store-password
   keyPassword=your-key-password
   keyAlias=upload
   storeFile=/path/to/upload-keystore.jks
   ```

3. Reference in `android/app/build.gradle`

### iOS

- Requires Apple Developer account ($99/year)
- Configure signing in Xcode
- Create App Store Connect listing
