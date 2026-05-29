# InvoiceFlow Pro — CodeCanyon Buyer Setup Guide

> **Product:** InvoiceFlow Pro  
> **Developer:** ADii Labs  
> **Document Version:** 1.0  
> **Last Updated:** 2026-05-27

---

## Table of Contents

1. [Overview](#1-overview)
2. [Environment Requirements](#2-environment-requirements)
3. [Initial Setup](#3-initial-setup)
4. [Build Instructions](#4-build-instructions)
5. [Project Structure Overview](#5-project-structure-overview)
6. [Rebranding Overview](#6-rebranding-overview)
7. [Localization System](#7-localization-system)
8. [Dependency Notes](#8-dependency-notes)
9. [Common Build Issues](#9-common-build-issues)
10. [Support Policy](#10-support-policy)
11. [Recommended Knowledge](#11-recommended-knowledge)

---

## 1. Overview

### Product Summary

**InvoiceFlow Pro** is a production-grade, offline-first invoicing application built with Flutter. It enables freelancers, small businesses, and micro-enterprises to create, manage, and export professional PDF invoices — entirely without an internet connection.

The app follows **Clean Architecture** principles with **Cubit** state management, a local database for persistence, and full **multilingual support** (English, Arabic, Urdu) including RTL layouts.

### Intended Buyers

| Buyer Type | Use Case |
|---|---|
| **Flutter Developers** | Launch a custom invoicing app under their own brand |
| **Freelance Developers** | Build client projects on a proven codebase |
| **Startup Teams** | Accelerate MVP development for fintech/business apps |
| **App Resellers** | White-label and resell with custom branding |
| **Agencies** | Deliver invoicing solutions to their clients |

### Skill Level Expectations

| Level | Suitable? | Notes |
|---|---|---|
| **Beginner** | ⚠️ Limited | Can run and build, but customization requires Flutter knowledge |
| **Intermediate** | ✅ Recommended | Comfortable with Flutter, Dart, and basic architecture concepts |
| **Advanced** | ✅ Ideal | Can extend features, add integrations, and customize deeply |

> **Important:** This is a professional-grade Flutter application, not a tutorial project. Basic Flutter and Dart proficiency is expected for any customization beyond branding.

---

## 2. Environment Requirements

### Required Software

| Tool | Minimum Version | Recommended Version | Notes |
|---|---|---|---|
| **Flutter SDK** | TODO: Specify | Latest stable channel | Run `flutter --version` to verify |
| **Dart SDK** | TODO: Specify | Bundled with Flutter | Included in Flutter SDK |
| **Android Studio** | TODO: Specify | Latest stable | Required for Android builds and emulators |
| **VS Code** | Latest | Latest | Alternative IDE, requires Flutter/Dart extensions |
| **Java JDK** | 11 | 17 | Required for Android Gradle builds |
| **Gradle** | TODO: Specify | Bundled with project | Uses Gradle wrapper (`gradlew`) |
| **Git** | 2.x | Latest | Required for dependency resolution |

### Android-Specific

| Requirement | Value |
|---|---|
| **Compile SDK** | TODO: Specify (e.g., 34) |
| **Min SDK** | TODO: Specify (e.g., 21 / Android 5.0) |
| **Target SDK** | TODO: Specify (e.g., 34) |
| **Build Tools** | TODO: Specify |
| **NDK** | TODO: Specify if required |

### iOS-Specific (Placeholder)

| Requirement | Value |
|---|---|
| **macOS** | Required for iOS builds |
| **Xcode** | TODO: Specify minimum version |
| **CocoaPods** | TODO: Specify version |
| **iOS Deployment Target** | TODO: Specify (e.g., 12.0) |

> **Note:** iOS build instructions are placeholders. The primary target platform is Android. iOS support requires a macOS machine with Xcode installed.

### System Requirements

| Requirement | Minimum | Recommended |
|---|---|---|
| **RAM** | 8 GB | 16 GB |
| **Disk Space** | 10 GB free | 20 GB free |
| **OS** | Windows 10 / macOS 11 / Ubuntu 20.04 | Latest stable |

---

## 3. Initial Setup

### Step 1: Extract the Project

Extract the downloaded ZIP archive to your preferred workspace directory.

```bash
# Example
unzip invoiceflow-pro-source.zip -d ~/projects/invoiceflow-pro
cd ~/projects/invoiceflow-pro
```

### Step 2: Verify Flutter Environment

```bash
flutter doctor
```

Ensure all required checks pass (Flutter, Android toolchain, IDE). Resolve any issues before proceeding.

### Step 3: Install Dependencies

```bash
flutter pub get
```

This downloads all Dart packages defined in `pubspec.yaml`.

### Step 4: Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- Dependency injection configuration
- Database model adapters
- JSON serialization code
- TODO: List other generated files specific to the project

> **Important:** You must run this command whenever you modify model classes, DI configuration, or any file with `@injectable`, `@JsonSerializable`, or similar annotations.

### Step 5: Generate Localization Files

```bash
flutter gen-l10n
```

This generates Dart localization classes from the `.arb` files in the `l10n/` (or `lib/l10n/`) directory.

### Step 6: Run the App

```bash
# Run on connected device or emulator
flutter run

# Run in debug mode with verbose logging
flutter run --verbose

# Run on a specific device
flutter devices              # List available devices
flutter run -d <device_id>   # Run on specific device
```

### Quick Start Summary

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

---

## 4. Build Instructions

### Android — Debug APK

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Android — Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android — App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

> **Note:** The Play Store requires AAB format. APKs are for direct distribution or testing only.

### Android — Split APKs by ABI

```bash
flutter build apk --release --split-per-abi
```

This produces separate APKs for `arm64-v8a`, `armeabi-v7a`, and `x86_64`, reducing individual APK size.

### Android — With Obfuscation

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

> **Important:** Keep the `build/debug-info/` directory. It is required to symbolicate crash reports.

### iOS — Build (Placeholder)

```bash
# Requires macOS with Xcode installed
cd ios && pod install && cd ..
flutter build ios --release
```

> **Note:** iOS builds require:
> - Apple Developer account ($99/year)
> - Valid provisioning profiles and certificates
> - Xcode configuration for signing
> - TODO: Provide detailed iOS build guide if iOS support is finalized

---

## 5. Project Structure Overview

```
lib/
├── app/                          # App-level configuration
│   ├── app.dart                  # MaterialApp / root widget
│   ├── routes.dart               # Named route definitions
│   └── theme/                    # Theme, colors, text styles
│
├── core/                         # Shared utilities & infrastructure
│   ├── constants/                # App-wide constants and enums
│   ├── di/                       # Dependency injection setup
│   ├── error/                    # Failure/exception classes
│   ├── extensions/               # Dart/Flutter extension methods
│   ├── utils/                    # Formatters, validators, helpers
│   └── widgets/                  # Shared reusable widgets
│
├── features/                     # Feature modules (Clean Architecture)
│   ├── dashboard/
│   │   ├── data/                 # Models, data sources, repo implementations
│   │   ├── domain/               # Entities, use cases, repo interfaces
│   │   └── presentation/         # Cubits, pages, widgets
│   │
│   ├── customers/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── invoices/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── items/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── settings/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── business_profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── pdf/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── backup/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── l10n/                         # ARB localization files
│   ├── app_en.arb
│   ├── app_ar.arb
│   └── app_ur.arb
│
└── main.dart                     # Entry point
```

> **Note:** This reflects the intended architecture. TODO: Verify exact folder structure matches the actual codebase and update if needed.

### Layer Responsibilities

| Layer | Purpose | Contains |
|---|---|---|
| **Data** | Data persistence & retrieval | Models (DTOs), data sources, repository implementations |
| **Domain** | Business logic (framework-independent) | Entities, use cases, repository interfaces |
| **Presentation** | UI & state management | Cubits, states, pages, feature-specific widgets |
| **Core** | Shared infrastructure | DI, error handling, utilities, shared widgets |

---

## 6. Rebranding Overview

> For the complete step-by-step rebranding guide, see [Rebranding & Customization Guide](rebranding_customization_guide.md).

### Quick Reference

| Element | Location | Tool/Method |
|---|---|---|
| **App Name** | `AndroidManifest.xml`, `Info.plist`, `pubspec.yaml` | Manual edit |
| **Package Name** | `build.gradle`, `AndroidManifest.xml`, Kotlin/Java files | `change_app_package_name` package or manual |
| **App Icon** | `assets/` or generated | `flutter_launcher_icons` package |
| **Splash Screen** | TODO: Specify | `flutter_native_splash` package |
| **Theme Colors** | `lib/app/theme/` | Edit theme files directly |
| **Fonts** | `assets/fonts/`, `pubspec.yaml` | Replace font files, update config |
| **Logo** | TODO: Specify asset path | Replace image files |

### Minimum Rebranding Checklist

- [ ] Change app name (Android + iOS)
- [ ] Change package name / bundle ID
- [ ] Replace app icon
- [ ] Replace splash screen
- [ ] Update theme colors
- [ ] Replace logo in invoice PDF template
- [ ] Update `pubspec.yaml` description
- [ ] Rebuild the app

---

## 7. Localization System

### Supported Languages

| Language | Code | Direction | ARB File |
|---|---|---|---|
| English | `en` | LTR | `app_en.arb` |
| Arabic | `ar` | RTL | `app_ar.arb` |
| Urdu | `ur` | RTL | `app_ur.arb` |

### Configuration

Localization is configured in `l10n.yaml` at the project root:

```yaml
# TODO: Verify exact l10n.yaml content
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### Adding a New Language

1. **Create a new ARB file:**
   ```bash
   # Example: Adding French
   cp lib/l10n/app_en.arb lib/l10n/app_fr.arb
   ```

2. **Translate all strings** in the new ARB file. Keep the keys identical; change only the values.

3. **Register the locale** in the app's `MaterialApp` configuration:
   ```dart
   // TODO: Verify exact location in the codebase
   supportedLocales: const [
     Locale('en'),
     Locale('ar'),
     Locale('ur'),
     Locale('fr'), // Add new locale
   ],
   ```

4. **Regenerate localization files:**
   ```bash
   flutter gen-l10n
   ```

5. **Test** the new language by switching locale in Settings.

### ARB File Format

```json
{
  "@@locale": "en",
  "appTitle": "InvoiceFlow Pro",
  "@appTitle": {
    "description": "The application title"
  },
  "dashboard": "Dashboard",
  "customers": "Customers",
  "invoices": "Invoices"
}
```

> **Important:** The English ARB file (`app_en.arb`) is the source of truth. All keys in other ARB files must match the English file exactly.

---

## 8. Dependency Notes

### Core Dependencies

| Package | Purpose | Version |
|---|---|---|
| **Isar** | Local NoSQL database for offline data persistence | TODO: Specify |
| **flutter_bloc** | State management (Cubit pattern) | TODO: Specify |
| **pdf** | PDF document generation for invoices | TODO: Specify |
| **printing** | PDF preview and printing | TODO: Specify |
| **get_it** | Service locator for dependency injection | TODO: Specify |
| **injectable** | Code generation for DI configuration | TODO: Specify |
| **flutter_localizations** | Built-in Flutter localization support | SDK |
| **intl** | Internationalization and date/number formatting | TODO: Specify |
| **path_provider** | Platform-specific file system paths | TODO: Specify |
| **share_plus** | Share files (PDF export) | TODO: Specify |

### Dev Dependencies

| Package | Purpose | Version |
|---|---|---|
| **build_runner** | Code generation runner | TODO: Specify |
| **injectable_generator** | DI code generation | TODO: Specify |
| **isar_generator** | Isar database model generation | TODO: Specify |
| **flutter_launcher_icons** | App icon generation | TODO: Specify |
| **flutter_native_splash** | Splash screen generation | TODO: Specify |

> **Note:** Exact package names and versions are defined in `pubspec.yaml`. Run `flutter pub deps` to see the full dependency tree.

### Dependency Compatibility

- All packages are selected for **offline-first** operation — no mandatory cloud dependencies.
- Isar provides high-performance local storage with full query support.
- The `pdf` package generates documents entirely on-device.
- TODO: Document any platform-specific dependency notes.

---

## 9. Common Build Issues

### Issue: Gradle Version Mismatch

**Symptom:** Build fails with Gradle compatibility errors.

**Solution:**
```bash
# Navigate to android directory
cd android

# Use the Gradle wrapper (recommended)
./gradlew --version

# If the wrapper is outdated, update gradle-wrapper.properties:
# distributionUrl=https\://services.gradle.org/distributions/gradle-X.X-all.zip
# TODO: Specify the correct Gradle version
```

### Issue: build_runner Conflicts

**Symptom:** Code generation fails with conflicting outputs.

**Solution:**
```bash
# Clean and regenerate
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Issue: Localization Generation Fails

**Symptom:** `flutter gen-l10n` produces errors or missing strings.

**Solution:**
1. Verify `l10n.yaml` exists at project root and is correctly configured.
2. Ensure all ARB files have matching keys.
3. Check for JSON syntax errors in ARB files.
4. Run:
   ```bash
   flutter gen-l10n --no-synthetic-package
   ```

### Issue: Isar Build Errors

**Symptom:** Isar-related generation or runtime errors.

**Solution:**
```bash
# Ensure Isar generator is in dev_dependencies
# Re-run code generation
dart run build_runner build --delete-conflicting-outputs

# If issues persist, clean everything
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Issue: General Build Cache Corruption

**Symptom:** Unexplained build failures after making changes.

**Solution:**
```bash
# Nuclear clean
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm -rf android/.gradle/
rm -rf ios/Pods/              # macOS only
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

### Issue: Android SDK Not Found

**Symptom:** Build fails with "SDK location not found."

**Solution:**
1. Open Android Studio → SDK Manager → Verify SDK path.
2. Create or update `android/local.properties`:
   ```properties
   sdk.dir=/path/to/Android/Sdk
   ```
3. Ensure `ANDROID_HOME` environment variable is set.

### Issue: Kotlin Version Mismatch

**Symptom:** Build fails with Kotlin compiler errors.

**Solution:**
```bash
# Update Kotlin version in android/build.gradle
# TODO: Specify the correct Kotlin version for this project
# ext.kotlin_version = 'X.X.X'
```

---

## 10. Support Policy

### ✅ Included in Purchase

| Support Area | Coverage |
|---|---|
| **Bug Fixes** | Fixes for bugs present in the original source code |
| **Installation Guidance** | Help with initial setup and first run |
| **Basic Setup Help** | Environment configuration, dependency resolution |
| **Build Assistance** | Help with APK/AAB generation for unmodified code |
| **Documentation Clarification** | Clarification on anything in this guide |

### ❌ Not Included in Purchase

| Area | Reason |
|---|---|
| **Custom Feature Development** | Requires separate contract/agreement |
| **Tax Law Customization** | Tax regulations vary by jurisdiction; legal expertise required |
| **Server / Backend Work** | V1 is offline-first; cloud features are out of scope |
| **Third-Party Integrations** | Payment gateways, CRMs, accounting software, etc. |
| **UI/UX Redesign** | Custom design work beyond branding changes |
| **iOS-Specific Build Issues** | iOS support is provided as-is (placeholder) |
| **App Store / Play Store Submission** | Publisher account and listing management |
| **Custom Localization/Translation** | Adding new languages beyond EN, AR, UR |
| **Performance Optimization** | For buyer-modified code |
| **Code Review** | For buyer-written customizations |

### Support Channels

| Channel | Response Time |
|---|---|
| **CodeCanyon Comments** | Within 48 business hours |
| **Email** | TODO: Add support email |
| **Support Period** | 6 months from purchase (standard CodeCanyon) |
| **Extended Support** | Available via CodeCanyon at additional cost |

### Support Request Guidelines

When contacting support, please include:
1. Your CodeCanyon purchase code
2. Flutter version (`flutter --version`)
3. Operating system
4. Complete error message or screenshot
5. Steps to reproduce the issue
6. Whether the code has been modified from the original

---

## 11. Recommended Knowledge

### Essential Skills

| Skill | Level | Purpose |
|---|---|---|
| **Dart Programming** | Intermediate | Core language for all app logic |
| **Flutter Framework** | Intermediate | Widget building, navigation, state management |
| **Android Build System** | Basic | Gradle, signing, manifest configuration |
| **Git Version Control** | Basic | Managing code changes |

### Beneficial Skills

| Skill | Level | Purpose |
|---|---|---|
| **Clean Architecture** | Basic | Understanding the project structure |
| **BLoC/Cubit Pattern** | Basic | Understanding state management |
| **Isar Database** | Basic | Data layer customization |
| **PDF Generation (Dart)** | Basic | Invoice template customization |
| **ARB Localization** | Basic | Adding/modifying translations |

### Placeholder — Firebase Knowledge

> Firebase is not used in V1. However, future versions (v2.0.0+) may incorporate:
> - **Firebase Authentication** — User sign-in
> - **Cloud Firestore** — Cloud data sync
> - **Firebase Crashlytics** — Crash reporting
> - **Firebase Analytics** — Usage analytics
>
> TODO: Update this section when Firebase integration is implemented.

### Recommended Resources

| Resource | URL |
|---|---|
| Flutter Official Docs | https://docs.flutter.dev |
| Dart Language Tour | https://dart.dev/language |
| flutter_bloc Documentation | https://bloclibrary.dev |
| Isar Documentation | https://isar.dev |
| Clean Architecture (Flutter) | TODO: Add recommended article/tutorial |
| CodeCanyon Author Guidelines | https://help.author.envato.com |

---

> _This guide is provided by ADii Labs to help CodeCanyon buyers get started quickly with InvoiceFlow Pro. For rebranding instructions, see the [Rebranding & Customization Guide](rebranding_customization_guide.md)._
