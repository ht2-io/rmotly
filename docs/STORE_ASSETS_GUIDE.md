# Store Assets Creation Guide

This guide explains how to create all required assets for the Google Play Store submission.

## Required Assets Checklist

- [ ] High-resolution icon (512x512 PNG)
- [ ] Feature graphic (1024x500 JPEG/PNG)
- [ ] Phone screenshots (2-8 images, recommended: 6)
- [ ] 7-inch tablet screenshots (optional, 2-8 images)
- [ ] 10-inch tablet screenshots (optional, 2-8 images)
- [ ] Promo video (optional, YouTube URL)

## Asset Specifications

### High-Resolution Icon

**Requirements:**
- Size: 512 x 512 pixels
- Format: 32-bit PNG with alpha channel
- File size: Max 1 MB
- Design: Should match your launcher icon

**Design Guidelines:**
- Simple, recognizable design
- Works at small sizes
- No transparency in safe zone (center 280x280)
- Use brand colors
- Avoid text (app name shown separately)

**Current Icon Location:**
- Check: `rmotly_app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- Current size: Likely 192x192
- **Action Required**: Create upscaled version to 512x512

**Creation Steps:**

1. **Export from existing icon:**
   ```bash
   # Use ImageMagick to upscale (install: brew install imagemagick)
   convert android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png \
     -resize 512x512 \
     -background transparent \
     -gravity center \
     -extent 512x512 \
     assets/store/icon-512.png
   ```

2. **Or design from scratch:**
   - Tools: Figma, Adobe Illustrator, Inkscape (free)
   - Export as 512x512 PNG with transparency
   - Use brand colors from `lib/core/theme/colors.dart`

### Feature Graphic

**Requirements:**
- Size: 1024 x 500 pixels
- Format: JPEG or 24-bit PNG (no alpha)
- File size: Max 1 MB
- Displays at top of store listing

**Design Guidelines:**
- Showcase app identity
- Include app icon/logo
- App name: "Rmotly"
- Tagline: "Your Controls. Your Server. Your Privacy."
- Avoid text in top/bottom 50px (may be cropped)
- Use high contrast for readability

**Recommended Layout:**
```
[Left: App Icon] [Center: App Name + Tagline] [Right: Device mockup]
```

**Creation Steps:**

1. **Using Canva (Free):**
   - Go to canva.com
   - Create custom size: 1024 x 500
   - Search templates: "app banner"
   - Customize with:
     - App icon
     - "Rmotly" text
     - Tagline: "Your Controls. Your Server. Your Privacy."
     - Privacy/self-hosted imagery
   - Export as PNG

2. **Using Figma (Free):**
   - Create frame: 1024 x 500
   - Import app icon
   - Add text layers
   - Export as PNG

3. **Template suggestion:**
   ```
   Background: Gradient (primary to secondary color)
   Left: App icon (200x200) at x:100
   Center: 
     - "Rmotly" (72pt, bold)
     - "Your Controls. Your Server. Your Privacy." (36pt)
   Right: Phone mockup with screenshot
   ```

### Phone Screenshots

**Requirements:**
- Format: JPEG or 24-bit PNG (no alpha)
- Minimum dimensions: 320px on shortest side
- Maximum dimensions: 3840px on longest side
- Aspect ratio: Between 16:9 and 9:16
- **Recommended**: 1080 x 1920 (9:16 portrait)
- Count: Minimum 2, recommended 6-8

**Screenshot Plan (Based on STORE_LISTING.md):**

1. **Dashboard View** (Main feature)
   - Show control grid with various types
   - Include button, toggle, slider widgets
   - Title overlay: "Customizable Dashboard"

2. **Control Editor**
   - Show control configuration screen
   - Display type selection
   - Title overlay: "Create Custom Controls"

3. **Actions List**
   - Show HTTP actions management
   - Include test buttons
   - Title overlay: "Trigger Any API"

4. **OpenAPI Import**
   - Show operation browser
   - Display API endpoint selection
   - Title overlay: "Import OpenAPI Specs"

5. **Notification Topics**
   - Show topics list with webhooks
   - Display enable/disable toggles
   - Title overlay: "Webhook Notifications"

6. **Settings/Theme**
   - Show dark mode and preferences
   - Display push notification settings
   - Title overlay: "Privacy-First Design"

**Taking Screenshots:**

#### Method 1: Android Emulator (Recommended)

```bash
# Start emulator
flutter emulators --launch <emulator_id>

# Or create new emulator
flutter emulators
# If none exist, create one in Android Studio:
# Tools → Device Manager → Create Device
# Choose: Pixel 7 Pro (1440 x 3120, 6.7")

# Run app
cd rmotly_app
flutter run

# Navigate to each screen
# Take screenshots: Android Studio → Running Devices → Camera icon
# Or: adb exec-out screencap -p > screenshot1.png
```

#### Method 2: Real Device

```bash
# Enable USB debugging on device
# Connect via USB

cd rmotly_app
flutter run

# Navigate to each screen, take screenshots
# Screenshots saved in device gallery

# Pull screenshots
adb pull /sdcard/DCIM/Screenshots/Screenshot*.png ./screenshots/
```

#### Method 3: Automated Screenshot Tool

```bash
# Install screenshot testing package
flutter pub add integration_test --dev
flutter pub add screenshots --dev

# Create screenshot tests in test_driver/
# Run: flutter drive --driver=test_driver/integration_test.dart
```

**Post-Processing:**

1. **Resize to standard dimensions:**
   ```bash
   # Install ImageMagick
   
   # Resize all screenshots
   for img in screenshots/*.png; do
     convert "$img" -resize 1080x1920 -gravity center -extent 1080x1920 "processed/${img##*/}"
   done
   ```

2. **Add title overlays (optional but recommended):**
   - Tools: Figma, Photoshop, or online tools
   - Add translucent bar at top/bottom
   - Add descriptive text (24-32pt, white with shadow)
   - Helps users understand each screenshot

3. **Optimize file size:**
   ```bash
   # Using pngquant for PNG
   pngquant --quality=80-95 screenshot*.png
   
   # Or convert to JPEG
   convert screenshot1.png -quality 85 screenshot1.jpg
   ```

### Tablet Screenshots (Optional)

**7-inch Tablet:**
- Recommended: 1200 x 1920 pixels
- Same content as phone screenshots
- Optimized for tablet layout

**10-inch Tablet:**
- Recommended: 1600 x 2560 pixels
- Showcase tablet-optimized layouts
- Show multi-column layouts if supported

**Note**: Only include if app has tablet-specific layouts. If app is primarily phone-focused, phone screenshots are sufficient.

## Screenshot Best Practices

### Do's:
✅ Show actual app functionality
✅ Use high-quality, clear images
✅ Demonstrate key features (one per screenshot)
✅ Include descriptive captions/overlays
✅ Use consistent device frame/style
✅ Show dark mode variant (optional)
✅ Order screenshots by importance

### Don'ts:
❌ Use misleading or exaggerated visuals
❌ Include copyrighted content
❌ Show personal/sensitive data
❌ Use blurry or pixelated images
❌ Include device UI (status bar OK, but not navigation)
❌ Use screenshots from other apps

## Screenshot Framing (Optional)

Add device frames for professional look:

**Tools:**
- [Device Art Generator](https://developer.android.com/distribute/marketing-tools/device-art-generator) (official)
- [Mockuphone](https://mockuphone.com/) (online)
- [Figma Device Mockups](https://www.figma.com/community/search?model_type=public_files&q=device%20mockup)

**Example with Device Art Generator:**
```bash
# Upload screenshots at developer.android.com/distribute/marketing-tools/device-art-generator
# Select device: Pixel 7 Pro
# Download framed images
```

## Asset Organization

Create this folder structure:

```
rmotly_app/assets/store/
├── icon-512.png
├── feature-graphic.png
├── screenshots/
│   ├── phone/
│   │   ├── 01-dashboard.png
│   │   ├── 02-control-editor.png
│   │   ├── 03-actions.png
│   │   ├── 04-openapi.png
│   │   ├── 05-topics.png
│   │   └── 06-settings.png
│   ├── tablet-7/
│   │   └── (optional)
│   └── tablet-10/
│       └── (optional)
└── video/ (optional)
    └── promo-video-link.txt
```

## Promo Video (Optional)

**Requirements:**
- Length: 30 seconds to 2 minutes
- Format: YouTube URL
- Aspect ratio: 16:9 or 9:16
- Resolution: 720p or 1080p

**Content Suggestions:**
- Quick overview of app features
- Showcase dashboard customization
- Demo control interactions
- Highlight privacy/self-hosted benefits
- Show action execution
- End with call-to-action

**Creation Tools:**
- Screen recording: Android Studio, OBS Studio
- Editing: DaVinci Resolve (free), iMovie, CapCut
- Upload to YouTube (can be unlisted)

## Quick Start Checklist

For minimal setup (just to get published):

- [ ] High-res icon (512x512) - Required
- [ ] Feature graphic (1024x500) - Required
- [ ] 2 phone screenshots minimum - Required
- [ ] More screenshots (up to 8) - Highly recommended
- [ ] Tablet screenshots - Optional
- [ ] Promo video - Optional

**Estimated time:**
- Minimal setup: 2-4 hours
- Complete setup: 1-2 days

## Tools Summary

**Free Tools:**
- Image editing: GIMP (gimp.org), Paint.NET
- Vector graphics: Inkscape (inkscape.org)
- Design: Figma (free tier), Canva (free tier)
- Screen recording: OBS Studio, Android Studio
- Image optimization: ImageMagick, pngquant
- Device frames: Device Art Generator (Google)

**Paid Tools (Optional):**
- Adobe Photoshop
- Adobe Illustrator
- Sketch (Mac only)
- Final Cut Pro / Adobe Premiere (video)

## Asset Quality Checklist

Before submitting:

- [ ] All images meet size requirements
- [ ] No blurry or pixelated images
- [ ] High-res icon has transparent background
- [ ] Feature graphic has no alpha channel
- [ ] Screenshots show actual app content
- [ ] No placeholder or "lorem ipsum" text
- [ ] Consistent style across all images
- [ ] File sizes under limits (1 MB each)
- [ ] Images named descriptively
- [ ] Screenshots ordered logically

## Getting Help

If you need design assistance:
1. Check Figma Community for templates
2. Use Canva templates (search "app store listing")
3. Hire on Fiverr/Upwork (budget: $50-200)
4. Post in r/androiddev for feedback
5. Join Flutter Discord for help

---

**Next**: After creating assets, see `PLAY_STORE_SUBMISSION.md` for upload and submission instructions.
