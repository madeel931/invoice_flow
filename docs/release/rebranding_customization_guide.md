# InvoiceFlow Pro — Rebranding & Customization Guide

> **Product:** InvoiceFlow Pro  
> **Developer:** ADii Labs  
> **Document Version:** 1.0  
> **Last Updated:** 2026-05-27

---

## Table of Contents

1. [App Name Change](#1-app-name-change)
2. [Package Name / Bundle ID Change](#2-package-name--bundle-id-change)
3. [App Icon Replacement](#3-app-icon-replacement)
4. [Splash Screen Replacement](#4-splash-screen-replacement)
5. [Theme & Colors](#5-theme--colors)
6. [Typography & Fonts](#6-typography--fonts)
7. [Logo Replacement](#7-logo-replacement)
8. [Invoice Branding](#8-invoice-branding)
9. [Localization Branding](#9-localization-branding)
10. [AdMob / Firebase Placeholders](#10-admob--firebase-placeholders)
11. [Build After Rebranding](#11-build-after-rebranding)
12. [Recommended White-Label Workflow](#12-recommended-white-label-workflow)

---

## Prerequisites

Before starting any rebranding:

- [ ] Back up the entire project (`git commit` or zip archive)
- [ ] Verify the app builds and runs successfully in its original state
- [ ] Have your branding assets ready (icon, logo, colors, fonts)
- [ ] Read through this entire guide before making changes

---

## 1. App Name Change

### Android

#### Launcher Name (what users see on home screen)

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Find and change: -->
<application
    android:label="InvoiceFlow Pro"  ← Change this
    ...>
```

**Change to your app name:**
```xml
<application
    android:label="Your App Name"
    ...>
```

> **Note:** If the app uses localized app names, also check for `android:label` references in:
> - `android/app/src/main/res/values/strings.xml`
> - `android/app/src/main/res/values-ar/strings.xml`
> - `android/app/src/main/res/values-ur/strings.xml`
>
> TODO: Verify if localized string resources exist for the app name.

#### Display Name in `pubspec.yaml`

**File:** `pubspec.yaml`

```yaml
name: invoice_flow_pro  # This is the Dart package name — see Section 2
description: Your App Description Here
```

### iOS (Placeholder)

**File:** `ios/Runner/Info.plist`

```xml
<!-- Find and change: -->
<key>CFBundleDisplayName</key>
<string>InvoiceFlow Pro</string>  ← Change this

<key>CFBundleName</key>
<string>InvoiceFlow Pro</string>  ← Change this
```

### In-App References

Search the entire codebase for hardcoded app name references:

```bash
grep -r "InvoiceFlow Pro" lib/
grep -r "InvoiceFlow" lib/
grep -r "invoiceflow" lib/
```

Update all occurrences in:
- [ ] App bar titles (if hardcoded)
- [ ] About screen / dialog
- [ ] PDF invoice headers (if the app name appears)
- [ ] Localization ARB files
- [ ] README.md

---

## 2. Package Name / Bundle ID Change

### Why Change?

The package name is the unique identifier for your app on the Play Store (and App Store). Two apps cannot have the same package name. You **must** change this before publishing.

### Android Package Name

**Current:** TODO: Verify (e.g., `com.adiilabs.invoiceflowpro`)

#### Option A: Using `change_app_package_name` Package (Recommended)

```bash
# Add to dev_dependencies temporarily
flutter pub add --dev change_app_package_name

# Run the package name change
flutter pub run change_app_package_name:main com.yourcompany.yourappname

# Remove after use
flutter pub remove change_app_package_name
```

This automatically updates:
- `AndroidManifest.xml` (all variants: main, debug, profile)
- `build.gradle` (applicationId)
- Kotlin/Java package directories and imports

#### Option B: Manual Change

1. **`android/app/build.gradle`:**
   ```groovy
   defaultConfig {
       applicationId "com.yourcompany.yourappname"  ← Change
       ...
   }
   ```

2. **`android/app/src/main/AndroidManifest.xml`:**
   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android"
       package="com.yourcompany.yourappname">  ← Change (if present)
   ```

3. **`android/app/src/debug/AndroidManifest.xml`:**
   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android"
       package="com.yourcompany.yourappname">  ← Change (if present)
   ```

4. **Kotlin/Java source directory:**
   Rename the directory structure to match:
   ```
   android/app/src/main/kotlin/com/yourcompany/yourappname/
   ```
   Update the package declaration in `MainActivity.kt`:
   ```kotlin
   package com.yourcompany.yourappname
   ```

### iOS Bundle ID (Placeholder)

**File:** `ios/Runner.xcodeproj/project.pbxproj` or via Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to General → Identity
4. Change **Bundle Identifier** to `com.yourcompany.yourappname`

**Or edit directly:**

**File:** `ios/Runner/Info.plist`
```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

The actual identifier is set in `ios/Runner.xcodeproj/project.pbxproj`:
```
PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.yourappname;
```

### Dart Package Name (Optional)

**File:** `pubspec.yaml`

```yaml
name: your_app_name  # lowercase with underscores
```

> **Warning:** Changing the Dart package name requires updating all `import` statements throughout the codebase. Use your IDE's refactoring tools:
> ```bash
> # Find all imports referencing the old name
> grep -r "package:invoice_flow_pro" lib/
> ```

---

## 3. App Icon Replacement

### Using `flutter_launcher_icons` (Recommended)

#### Step 1: Prepare Your Icon

| Requirement | Value |
|---|---|
| **Size** | 1024 × 1024 px (minimum) |
| **Format** | PNG |
| **Background** | Solid color or transparent |
| **Shape** | Square (adaptive icon system handles masking) |

#### Step 2: Place Icon File

```bash
# Place your icon in the assets directory
# Example: assets/icon/app_icon.png
```

#### Step 3: Configure `pubspec.yaml`

```yaml
# Add or update flutter_launcher_icons configuration
flutter_launcher_icons:
  android: true
  ios: true  # Set false if not targeting iOS
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#FFFFFF"  # Your background color
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"

  # Android-specific
  min_sdk_android: 21

  # Web (if applicable)
  web:
    generate: false
```

> **TODO:** Verify if `flutter_launcher_icons` is already in `dev_dependencies`. If not:
> ```bash
> flutter pub add --dev flutter_launcher_icons
> ```

#### Step 4: Generate Icons

```bash
dart run flutter_launcher_icons
```

This generates all required icon sizes for Android and iOS.

#### Step 5: Verify

- [ ] Check `android/app/src/main/res/mipmap-*` directories for new icons
- [ ] Check adaptive icon renders correctly on multiple launcher shapes
- [ ] Uninstall old app and reinstall to clear icon cache

---

## 4. Splash Screen Replacement

### Using `flutter_native_splash` (Recommended)

#### Step 1: Prepare Splash Assets

| Asset | Specification |
|---|---|
| **Splash Image** | PNG, centered logo/icon, 1152 × 1152 px (recommended) |
| **Background Color** | Hex color matching your brand |
| **Dark Mode Image** | Optional, different logo for dark mode |

#### Step 2: Configure `pubspec.yaml`

```yaml
flutter_native_splash:
  color: "#FFFFFF"  # Background color (light mode)
  image: assets/splash/splash_logo.png

  # Dark mode (optional)
  color_dark: "#121212"
  image_dark: assets/splash/splash_logo_dark.png

  # Android 12+ specific
  android_12:
    color: "#FFFFFF"
    icon_background_color: "#FFFFFF"
    image: assets/splash/splash_logo_android12.png

  # Platforms
  android: true
  ios: true  # Set false if not targeting iOS
  web: false
```

> **TODO:** Verify if `flutter_native_splash` is already in `dev_dependencies`. If not:
> ```bash
> flutter pub add --dev flutter_native_splash
> ```

#### Step 3: Generate Splash Screen

```bash
dart run flutter_native_splash:create
```

#### Step 4: Verify

- [ ] Cold start shows new splash screen
- [ ] Splash screen transitions smoothly to app
- [ ] Dark mode splash displays correctly (if configured)
- [ ] Android 12+ splash follows new guidelines

---

## 5. Theme & Colors

### Locating Theme Files

The app's theme is defined in the theme directory:

```
lib/app/theme/
├── app_theme.dart        # ThemeData configuration
├── app_colors.dart       # Color constants
└── app_text_styles.dart  # Text style definitions
```

> **TODO:** Verify the exact file paths and names in the codebase.

### Changing Primary Colors

**File:** TODO: Specify exact path (e.g., `lib/app/theme/app_colors.dart`)

```dart
// TODO: Find and replace these color definitions
class AppColors {
  // Primary brand colors
  static const primary = Color(0xFFYOURCOLOR);      // Your primary color
  static const primaryDark = Color(0xFFYOURCOLOR);   // Darker variant
  static const primaryLight = Color(0xFFYOURCOLOR);  // Lighter variant
  static const accent = Color(0xFFYOURCOLOR);        // Accent/secondary color

  // Surface colors
  static const background = Color(0xFFYOURCOLOR);
  static const surface = Color(0xFFYOURCOLOR);
  static const error = Color(0xFFYOURCOLOR);

  // Dark mode variants
  static const backgroundDark = Color(0xFFYOURCOLOR);
  static const surfaceDark = Color(0xFFYOURCOLOR);
}
```

### Changing ThemeData

**File:** TODO: Specify exact path (e.g., `lib/app/theme/app_theme.dart`)

```dart
// TODO: Find and update ThemeData configuration
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,  // Your primary brand color
    brightness: Brightness.light,
  ),
  // ... other theme properties
)
```

### Color Recommendations

| Purpose | Recommendation |
|---|---|
| **Primary** | Your main brand color |
| **Secondary** | Complementary color |
| **Error** | Red variant (standard UX convention) |
| **Success** | Green variant |
| **Warning** | Amber/orange variant |
| **Background** | Light: #FAFAFA–#FFFFFF, Dark: #121212–#1E1E1E |
| **Surface** | Slightly different from background for cards/sheets |

### Finding All Color References

```bash
# Find hardcoded colors (bad practice, but check)
grep -rn "Color(0x" lib/
grep -rn "Colors\." lib/

# Find theme color references
grep -rn "AppColors\." lib/
grep -rn "Theme.of" lib/
```

---

## 6. Typography & Fonts

### Replacing Fonts

#### Step 1: Add Font Files

Place your `.ttf` or `.otf` files in:
```
assets/fonts/
├── YourFont-Regular.ttf
├── YourFont-Medium.ttf
├── YourFont-SemiBold.ttf
├── YourFont-Bold.ttf
└── YourArabicFont-Regular.ttf  # For RTL languages
```

#### Step 2: Register in `pubspec.yaml`

```yaml
flutter:
  fonts:
    - family: YourFont
      fonts:
        - asset: assets/fonts/YourFont-Regular.ttf
          weight: 400
        - asset: assets/fonts/YourFont-Medium.ttf
          weight: 500
        - asset: assets/fonts/YourFont-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/YourFont-Bold.ttf
          weight: 700

    - family: YourArabicFont
      fonts:
        - asset: assets/fonts/YourArabicFont-Regular.ttf
          weight: 400
```

#### Step 3: Update Theme

```dart
// TODO: Find and update font family references
ThemeData(
  fontFamily: 'YourFont',
  // ...
)
```

#### Step 4: Update PDF Fonts (Important!)

The PDF generation system uses embedded fonts separately from the app UI. You must also update:

- [ ] TODO: Locate PDF font loading code
- [ ] Replace font files used for PDF generation
- [ ] Verify Arabic/Urdu PDF fonts render correctly
- [ ] Test PDF output with new fonts

> **Critical:** PDF fonts and app UI fonts are independent. Changing one does not affect the other.

### Font Recommendations

| Language | Recommended Fonts |
|---|---|
| **English** | Inter, Roboto, Poppins, Montserrat, Open Sans |
| **Arabic** | Amiri, Noto Naskh Arabic, Cairo, Tajawal |
| **Urdu** | Noto Nastaliq Urdu, Jameel Noori Nastaleeq |

---

## 7. Logo Replacement

### Where Logos Are Used

| Location | File Path | Format |
|---|---|---|
| **App icon** | See [Section 3](#3-app-icon-replacement) | PNG |
| **Splash screen** | See [Section 4](#4-splash-screen-replacement) | PNG |
| **Business profile default** | TODO: Verify asset path | PNG/JPEG |
| **PDF invoice header** | TODO: Verify PDF template code | PNG/JPEG |
| **About screen** | TODO: Verify if logo appears | PNG |

### Logo Specifications

| Usage | Size | Format | Notes |
|---|---|---|---|
| **App Icon Source** | 1024×1024 px | PNG | Used to generate all icon sizes |
| **Splash Screen** | 1152×1152 px | PNG | Transparent background recommended |
| **PDF Header** | 200×200 px (max) | PNG/JPEG | Will be embedded in PDF, keep file size small |
| **In-App Display** | Various | PNG | Use SVG if supported for scalability |

### Finding All Logo References

```bash
# Find image asset references
grep -rn "assets/" lib/ | grep -i "logo\|icon\|brand"
grep -rn "AssetImage\|Image.asset" lib/
```

---

## 8. Invoice Branding

### What to Customize on Invoices

The PDF invoice template includes branding elements that should be updated:

| Element | Location | How to Change |
|---|---|---|
| **Company logo** | Business profile → Logo | User sets via app UI |
| **Invoice title** | PDF template code | TODO: Locate in source code |
| **Footer text** | PDF template code | TODO: Locate in source code |
| **Color accents** | PDF template code | TODO: Locate in source code |
| **Font** | PDF font configuration | See [Section 6](#6-typography--fonts) |

### PDF Template Customization

```bash
# Find the PDF generation code
# TODO: Verify exact file path
# Likely locations:
grep -rn "pdf\|Pdf\|PDF" lib/features/pdf/
```

### Customizable PDF Elements

| Element | Customizable? | How |
|---|---|---|
| Header layout | TODO | Edit PDF builder code |
| Company info position | TODO | Edit PDF builder code |
| Line item table style | TODO | Edit PDF builder code |
| Color scheme | TODO | Update PDF color constants |
| Font | TODO | Replace embedded font files |
| Footer content | TODO | Edit PDF builder code |
| Page margins | TODO | Edit PDF layout constants |
| Logo size/position | TODO | Edit PDF builder code |

> **Note:** PDF template customization requires Dart programming knowledge and familiarity with the `pdf` package API. TODO: Add link to PDF package documentation.

---

## 9. Localization Branding

### Updating Brand References in Translations

All user-facing brand text is in the ARB localization files. Update these with your brand name:

**Files to update:**
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ar.arb`
- `lib/l10n/app_ur.arb`

> **TODO:** Verify exact location of ARB files.

```bash
# Find all brand references in ARB files
grep -n "InvoiceFlow\|ADii Labs\|invoiceflow" lib/l10n/*.arb
```

### Keys to Update

| Key (Example) | Original Value | Your Value |
|---|---|---|
| `appTitle` | "InvoiceFlow Pro" | "Your App Name" |
| TODO: `aboutAppName` | TODO | Your app name |
| TODO: `aboutDeveloper` | "ADii Labs" | Your company name |
| TODO: Other brand references | TODO | Your brand |

### After Updating Translations

```bash
flutter gen-l10n
```

Verify:
- [ ] App title updated in all 3 languages
- [ ] About screen shows your brand
- [ ] No remaining references to "InvoiceFlow" or "ADii Labs"

---

## 10. AdMob / Firebase Placeholders

### Firebase Configuration (Not Active in V1)

InvoiceFlow Pro V1 does not use Firebase. If you plan to add Firebase services:

#### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add Android app with **your** package name
4. Download `google-services.json`

#### Step 2: Place Configuration File

```
android/app/google-services.json  ← Place here
```

#### Step 3: Add Firebase Dependencies

```yaml
# pubspec.yaml — add as needed
dependencies:
  firebase_core: ^TODO
  firebase_analytics: ^TODO      # Usage analytics
  firebase_crashlytics: ^TODO    # Crash reporting
  firebase_auth: ^TODO           # User authentication (V2)
  cloud_firestore: ^TODO         # Cloud sync (V2)
```

#### Step 4: Initialize Firebase

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // ... rest of initialization
}
```

### AdMob Integration (Not Recommended)

> **ADii Labs does not recommend ads in business/invoicing apps.** Ads undermine the professional image and user trust required for financial software.

If you choose to add AdMob despite this recommendation:

| Step | Action |
|---|---|
| 1 | Create AdMob account at [admob.google.com](https://admob.google.com) |
| 2 | Register your app and get App ID |
| 3 | Add `google_mobile_ads` package to `pubspec.yaml` |
| 4 | Add AdMob App ID to `AndroidManifest.xml` |
| 5 | Implement ad widgets in appropriate screens |
| 6 | Update privacy policy to disclose ad data collection |
| 7 | Update Play Store data safety form |

> **Warning:** Adding ads requires updating your privacy policy and data safety disclosures. Ad SDKs collect device data, advertising IDs, and usage patterns.

### iOS Firebase Configuration (Placeholder)

```
ios/Runner/GoogleService-Info.plist  ← Place here (from Firebase Console)
```

> **TODO:** Add detailed iOS Firebase setup instructions when iOS build is finalized.

---

## 11. Build After Rebranding

### Complete Rebuild Checklist

After making branding changes, perform a clean rebuild:

```bash
# Step 1: Clean everything
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm -rf android/.gradle/

# Step 2: Reinstall dependencies
flutter pub get

# Step 3: Regenerate code
dart run build_runner build --delete-conflicting-outputs

# Step 4: Regenerate localizations
flutter gen-l10n

# Step 5: Regenerate icons (if changed)
dart run flutter_launcher_icons

# Step 6: Regenerate splash screen (if changed)
dart run flutter_native_splash:create

# Step 7: Test in debug mode
flutter run

# Step 8: Test in release mode
flutter run --release

# Step 9: Build release artifact
flutter build appbundle --release
```

### Post-Rebranding Verification

| Check | Status |
|---|---|
| App name correct on launcher | [ ] |
| App icon correct on launcher | [ ] |
| Splash screen shows new branding | [ ] |
| Theme colors match your brand | [ ] |
| Fonts render correctly (EN, AR, UR) | [ ] |
| Logo appears correctly in app | [ ] |
| PDF invoice shows your branding | [ ] |
| About screen shows your company | [ ] |
| No references to "InvoiceFlow" or "ADii Labs" | [ ] |
| App builds in release mode without errors | [ ] |
| App passes basic smoke test in release mode | [ ] |

### Search for Remaining References

```bash
# Final check: no original branding remains
grep -rn "InvoiceFlow" lib/ android/ ios/ pubspec.yaml
grep -rn "ADii Labs" lib/ android/ ios/ pubspec.yaml
grep -rn "adiilabs" lib/ android/ ios/ pubspec.yaml
grep -rn "adii_labs" lib/ android/ ios/ pubspec.yaml
```

---

## 12. Recommended White-Label Workflow

### Overview

If you plan to create multiple branded versions of the app (white-labeling), follow this structured workflow:

### Step 1: Create a Brand Configuration File

Create a centralized configuration that defines all brand-specific values:

```dart
// TODO: This is a recommended pattern, not currently implemented
// lib/core/config/brand_config.dart

class BrandConfig {
  static const String appName = 'Your App Name';
  static const String companyName = 'Your Company';
  static const String packageName = 'com.yourcompany.yourapp';

  // Colors
  static const Color primaryColor = Color(0xFFYOURCOLOR);
  static const Color accentColor = Color(0xFFYOURCOLOR);

  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String iconPath = 'assets/icon/app_icon.png';

  // Contact
  static const String supportEmail = 'support@yourcompany.com';
  static const String websiteUrl = 'https://yourcompany.com';
  static const String privacyPolicyUrl = 'https://yourcompany.com/privacy';
}
```

### Step 2: Use Flavor/Build Variants (Advanced)

For managing multiple brands efficiently:

```
├── flavors/
│   ├── brand_a/
│   │   ├── assets/
│   │   │   ├── icon/
│   │   │   ├── splash/
│   │   │   └── logo/
│   │   ├── brand_config.dart
│   │   └── google-services.json
│   │
│   ├── brand_b/
│   │   ├── assets/
│   │   ├── brand_config.dart
│   │   └── google-services.json
│   │
│   └── brand_c/
│       └── ...
```

```bash
# Build specific brand
flutter build apk --release --flavor brandA
flutter build apk --release --flavor brandB
```

> **Note:** This is an advanced workflow. For a single rebrand, the manual process in Sections 1–10 is sufficient.

### Step 3: White-Label Checklist

For each new brand, complete:

- [ ] Choose unique package name
- [ ] Prepare brand assets (icon, splash, logo, colors)
- [ ] Update app name (all platforms)
- [ ] Update package name / bundle ID
- [ ] Generate app icons
- [ ] Generate splash screen
- [ ] Update theme colors
- [ ] Update fonts
- [ ] Replace logos (app and PDF)
- [ ] Update localization strings
- [ ] Configure Firebase (if applicable)
- [ ] Update privacy policy URL
- [ ] Clean build and test
- [ ] Verify no original branding remains
- [ ] Build release artifact
- [ ] Test release artifact on device

### Step 4: Maintain a Rebranding Log

| Field | Original | Brand A | Brand B |
|---|---|---|---|
| App Name | InvoiceFlow Pro | TODO | TODO |
| Package Name | TODO | TODO | TODO |
| Primary Color | TODO | TODO | TODO |
| Firebase Project | N/A | TODO | TODO |
| Play Store Email | TODO | TODO | TODO |
| Privacy Policy URL | TODO | TODO | TODO |
| Release Date | TODO | TODO | TODO |

---

## Appendix: File Reference

### Files Modified During Rebranding

| File | What Changes |
|---|---|
| `pubspec.yaml` | App name, description, fonts, assets |
| `android/app/build.gradle` | applicationId, signing config |
| `android/app/src/main/AndroidManifest.xml` | App label, permissions |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Package declaration |
| `android/app/src/main/res/mipmap-*/*` | App icons (generated) |
| `ios/Runner/Info.plist` | Bundle display name, bundle name |
| `ios/Runner.xcodeproj/project.pbxproj` | Bundle identifier |
| `lib/app/theme/app_colors.dart` | Brand colors |
| `lib/app/theme/app_theme.dart` | Font family, theme config |
| `lib/l10n/app_en.arb` | App name, brand text (English) |
| `lib/l10n/app_ar.arb` | App name, brand text (Arabic) |
| `lib/l10n/app_ur.arb` | App name, brand text (Urdu) |
| `assets/icon/` | App icon source |
| `assets/splash/` | Splash screen image |
| `assets/images/logo.*` | In-app logo |
| TODO: PDF font files | Invoice fonts |
| TODO: PDF template code | Invoice header/footer |

> **Note:** Exact file paths may vary. Use `grep` to locate specific references as shown throughout this guide. TODO: Verify all paths against the actual codebase.

---

> _This guide is provided by ADii Labs for CodeCanyon buyers. For setup instructions, see the [CodeCanyon Setup Guide](codecanyon_setup_guide.md). For Play Store compliance, see the [Play Store Compliance Guide](playstore_compliance_guide.md)._
