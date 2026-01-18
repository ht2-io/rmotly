# Getting Started with Rmotly

Welcome to Rmotly! This guide will help you get started with your privacy-first, self-hosted remote control and notification system.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installing the App](#installing-the-app)
- [Initial Setup](#initial-setup)
- [Creating Your First Account](#creating-your-first-account)
- [Your First Control](#your-first-control)
- [Testing Your Control](#testing-your-control)
- [Receiving Notifications](#receiving-notifications)
- [Next Steps](#next-steps)

## Overview

Rmotly allows you to:
- Create custom dashboard controls that trigger HTTP actions
- Control smart home devices, APIs, and web services
- Receive notifications from external systems via webhooks
- Keep all your data on your own server

## Prerequisites

Before installing the Rmotly app, you need:

### 1. A Rmotly Server

Your server administrator should provide you with:
- **Server URL** - The address of your Rmotly server (e.g., `https://api.yourdomain.com`)
- **Server status** - Confirmation that the server is running and accessible

If you're self-hosting, follow the [Deployment Guide](DEPLOYMENT.md) to set up your server.

### 2. Network Access

- Your device must be able to reach the server URL
- If using a local network, ensure your device is connected to the same network
- For remote access, your server must be accessible from the internet

### 3. An Android Device

Currently, Rmotly is available for:
- **Android 8.0 (Oreo)** or newer
- iOS support is planned for future releases

## Installing the App

### From Google Play Store

1. Open the **Google Play Store** on your Android device
2. Search for **"Rmotly"**
3. Tap **Install**
4. Wait for the installation to complete
5. Tap **Open** to launch the app

### From APK File

If you're installing from an APK file (for testing or beta versions):

1. **Enable installation from unknown sources:**
   - Open **Settings** on your device
   - Go to **Security** (or **Privacy**)
   - Enable **Install unknown apps** or **Unknown sources**
   - Select your file manager or browser and allow installations

2. **Download the APK:**
   - Download the Rmotly APK file provided by your administrator
   - The file will typically download to your `Downloads` folder

3. **Install the APK:**
   - Open your file manager
   - Navigate to the `Downloads` folder
   - Tap the **Rmotly APK** file
   - Tap **Install**
   - Tap **Open** when installation completes

### For Self-Hosted Deployments

If you're building from source:

```bash
cd rmotly_app
flutter build apk --release
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## Initial Setup

### 1. Launch the App

When you first open Rmotly, you'll see the welcome screen.

### 2. Configure Server Connection

1. Tap **Get Started** or **Configure Server**
2. Enter your **Server URL**:
   - Include the protocol: `https://api.yourdomain.com` or `http://192.168.1.100:8080`
   - Do not include a trailing slash
   - For local development: `http://localhost:8080`

3. Tap **Connect**

The app will test the connection to your server. If successful, you'll see a green checkmark and proceed to account creation.

### Common Connection Issues

| Issue | Solution |
|-------|----------|
| **Cannot connect** | Verify the server URL is correct and the server is running |
| **SSL certificate error** | Ensure your HTTPS certificate is valid, or use HTTP for testing |
| **Timeout** | Check your network connection and firewall settings |
| **Wrong protocol** | Make sure to use `https://` for secure servers or `http://` for development |

## Creating Your First Account

### New Account Registration

1. On the login screen, tap **Create Account**

2. **Choose a username:**
   - 3-20 characters
   - Letters, numbers, and underscores only
   - Example: `john_doe` or `alice123`

3. **Enter your email address:**
   - Used for account recovery and notifications
   - Must be a valid email address
   - Example: `john@example.com`

4. **Create a password:**
   - Minimum 8 characters
   - Include uppercase, lowercase, numbers, and symbols for security
   - Example: `MySecure@Pass2024`

5. **Confirm your password:**
   - Re-enter the same password

6. Tap **Sign Up**

### Email Verification

After registration, you'll receive a verification email:

1. **Check your inbox** for an email from your Rmotly server
2. **Copy the verification code** (6 digits)
3. **Return to the app**
4. **Enter the verification code**
5. Tap **Verify**

### Login to Existing Account

If you already have an account:

1. On the login screen, enter your **email** and **password**
2. Tap **Sign In**
3. You'll be taken to your dashboard

## Your First Control

Let's create a simple button control that triggers an HTTP request.

### Step 1: Open Control Editor

1. From your empty dashboard, tap the **+ (Add)** button
2. Or tap the **menu icon** (☰) and select **Add Control**

### Step 2: Choose Control Type

Select **Button** from the control type options:

| Control Type | Best For |
|--------------|----------|
| **Button** | Single-tap actions (turn on/off, trigger event) |
| **Toggle** | On/off switches with state |
| **Slider** | Adjusting values (volume, brightness) |
| **Input** | Sending text or data |
| **Dropdown** | Choosing from predefined options |

### Step 3: Configure Basic Settings

1. **Name your control:**
   - Enter a descriptive name: `Test Button`
   - This appears on your dashboard

2. **Choose an icon (optional):**
   - Tap the icon selector
   - Browse available icons
   - Select one that represents your action (e.g., lightbulb, power)

3. **Pick a color (optional):**
   - Tap the color picker
   - Choose a color that stands out
   - Default colors work fine too

### Step 4: Create an Action

Now we need to define what happens when you press the button.

1. **Tap "Create New Action"** (or select an existing one if available)

2. **Name your action:**
   - Example: `HTTP Request Test`

3. **Select HTTP method:**
   - Choose **GET** for a simple test
   - Other options: POST, PUT, DELETE, PATCH

4. **Enter the URL:**
   - For testing, use: `https://httpbin.org/get`
   - This is a free API that echoes back your request

5. **Add headers (optional):**
   - Tap **Add Header**
   - For now, leave this empty

6. **Tap Save** to create the action

### Step 5: Finish Control Setup

1. Review your control settings
2. Tap **Save** or **Create Control**
3. Your new button appears on the dashboard!

### Example: Complete Button Configuration

```
Control Settings:
├── Name: Test Button
├── Type: Button
├── Icon: check_circle
├── Color: Green (#4CAF50)
└── Action: HTTP Request Test
    ├── Method: GET
    ├── URL: https://httpbin.org/get
    └── Headers: (none)
```

## Testing Your Control

### Execute Your Control

1. **Find your control** on the dashboard
2. **Tap the button**
3. Watch for visual feedback:
   - The button will briefly show a "pressed" animation
   - A success checkmark or error icon will appear
   - A toast message shows the result

### View Action Results

1. **Tap and hold** your control (long-press)
2. Select **View Last Result**
3. You'll see:
   - HTTP status code (200 = success)
   - Response body
   - Execution time
   - Any errors

### Troubleshooting

If your control doesn't work:

| Problem | Check |
|---------|-------|
| **No response** | Verify your device has internet access |
| **Error 404** | URL is incorrect - check for typos |
| **Error 401/403** | Authentication required - add API key to headers |
| **Timeout** | URL is unreachable or server is slow |
| **SSL error** | Certificate issue - check HTTPS configuration |

## Receiving Notifications

Rmotly can receive notifications from external systems through webhook topics.

### Step 1: Create a Notification Topic

1. Tap the **menu icon** (☰)
2. Select **Notification Topics**
3. Tap the **+ (Add)** button
4. **Name your topic:**
   - Example: `Server Alerts`
5. **Add a description (optional):**
   - Example: `Notifications from my home server`
6. Tap **Create**

### Step 2: Get Your Webhook URL

After creating the topic, you'll see:

1. **Webhook URL:**
   ```
   https://api.yourdomain.com/api/notify/topic_abc123
   ```
   Tap to copy this URL

2. **API Key:**
   ```
   rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx
   ```
   Tap to copy this key

### Step 3: Test Your Webhook

Use curl to send a test notification:

```bash
curl -X POST https://api.yourdomain.com/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Notification",
    "message": "Hello from Rmotly!"
  }'
```

You should receive a notification on your device within seconds!

### Step 4: Configure Push Notifications (Optional)

For notifications when the app is closed:

1. Go to **Settings** → **Notifications**
2. Tap **Configure Push Notifications**
3. **Choose a distributor:**
   - **ntfy** (self-hosted, recommended for privacy)
   - **FCM** (Google's service, optional)
4. Follow the setup wizard
5. Grant notification permissions when prompted

See the [User Guide](USER_GUIDE.md#notification-topics) for detailed push notification setup.

## Next Steps

Congratulations! You've successfully set up Rmotly and created your first control.

### Learn More

- **[User Guide](USER_GUIDE.md)** - Complete guide to all features
- **[Controls Guide](CONTROLS_GUIDE.md)** - Detailed guide for each control type
- **[Troubleshooting](TROUBLESHOOTING.md)** - Solutions to common issues

### Explore More Features

1. **Import from OpenAPI:**
   - Automatically create actions from API specifications
   - See: [User Guide - OpenAPI Import](USER_GUIDE.md#openapi-import)

2. **Create Advanced Controls:**
   - Use toggles for stateful on/off switches
   - Use sliders for adjusting ranges
   - See: [Controls Guide](CONTROLS_GUIDE.md)

3. **Use Template Variables:**
   - Dynamic URLs and payloads
   - Variable substitution with `{{variables}}`
   - See: [User Guide - Using Actions](USER_GUIDE.md#using-actions)

4. **Organize Your Dashboard:**
   - Reorder controls by dragging
   - Create logical groupings
   - Customize layout and appearance

5. **Connect Real Services:**
   - Home Assistant integration
   - Smart home devices
   - Custom APIs and webhooks

### Get Help

If you need assistance:

- **Check the [Troubleshooting Guide](TROUBLESHOOTING.md)**
- **Review the [User Guide](USER_GUIDE.md)**
- **Contact your server administrator**
- **Visit the project repository for updates**

### Privacy & Security

Rmotly is designed with privacy in mind:

- All data stays on your server
- No telemetry or tracking
- End-to-end encrypted notifications
- Self-hosted push notifications option

For more information, see the [Privacy Policy](PRIVACY_POLICY.md).

---

## Quick Reference Card

### Your Credentials
```
Server URL:  _________________________
Email:       _________________________
Password:    (stored securely)
```

### Important Links
```
Dashboard:        (Home screen in app)
Notification Topics:  Menu → Notification Topics
Actions:          Menu → Actions
Settings:         Menu → Settings
```

### Getting Support
```
Server Admin:     _________________________
Documentation:    docs/USER_GUIDE.md
Issues:           (Project repository)
```

---

**Ready to dive deeper?** Continue to the [User Guide](USER_GUIDE.md) for comprehensive documentation of all Rmotly features.
