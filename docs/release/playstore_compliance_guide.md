# InvoiceFlow Pro — Play Store Compliance Guide

> **Product:** InvoiceFlow Pro  
> **Developer:** ADii Labs  
> **Document Version:** 1.0  
> **Last Updated:** 2026-05-27

---

## Table of Contents

1. [Play Store Readiness Overview](#1-play-store-readiness-overview)
2. [Privacy Policy Strategy](#2-privacy-policy-strategy)
3. [Data Collection Disclosure](#3-data-collection-disclosure)
4. [Android Permissions](#4-android-permissions)
5. [Release Build Checklist](#5-release-build-checklist)
6. [ProGuard / R8 Notes](#6-proguard--r8-notes)
7. [Play Store Assets](#7-play-store-assets)
8. [Content Rating](#8-content-rating)
9. [Monetization Strategy](#9-monetization-strategy)
10. [Post-Launch Monitoring](#10-post-launch-monitoring)

---

## 1. Play Store Readiness Overview

This document covers everything required to achieve and maintain Play Store compliance for InvoiceFlow Pro. It is designed to be used alongside the [Play Store Release Checklist](playstore_release_checklist.md) and should be reviewed before every production release.

### Compliance Areas

| Area | Status | Notes |
|---|---|---|
| Privacy Policy | TODO | Must be published before submission |
| Data Safety Form | TODO | Required in Play Console |
| Permissions | TODO | Audit and justify all requested permissions |
| Content Rating | TODO | Complete rating questionnaire |
| Target Audience | TODO | Define and declare in Play Console |
| App Signing | TODO | Enroll in Play App Signing |
| Release Build | TODO | AAB format, obfuscated |
| Store Listing | TODO | All assets and descriptions ready |

### Google Play Policy References

| Policy | Relevance |
|---|---|
| [User Data Policy](https://support.google.com/googleplay/android-developer/answer/10144311) | Data collection, sharing, security |
| [Permissions Policy](https://support.google.com/googleplay/android-developer/answer/9214102) | Minimum necessary permissions |
| [Families Policy](https://support.google.com/googleplay/android-developer/answer/9893335) | Not applicable (business app) |
| [Financial Services Policy](https://support.google.com/googleplay/android-developer/answer/9876821) | Invoicing is not regulated financial service |
| [Ads Policy](https://support.google.com/googleplay/android-developer/answer/9857753) | Only if ads are implemented |

---

## 2. Privacy Policy Strategy

### Architecture Advantage: Offline-First

InvoiceFlow Pro V1 operates **entirely offline**. This significantly simplifies the privacy policy because:

- **No user accounts** — No authentication system in V1
- **No cloud storage** — All data stored locally on the user's device
- **No data transmission** — No data sent to external servers
- **No third-party data sharing** — No data shared with advertisers or analytics providers
- **User-controlled data** — Users can export and delete all their data

### Privacy Policy Content Requirements

The privacy policy must clearly state:

| Section | Content |
|---|---|
| **Data Storage** | All invoice, customer, and product data is stored locally on the device using an embedded database (Isar). No data is transmitted to external servers. |
| **Data Collection** | The app does not collect personal data from users. Business information entered (company name, logo, address) is stored locally for invoice generation purposes only. |
| **Data Sharing** | No user data is shared with third parties. |
| **Data Export** | Users can export their data via the backup feature (JSON format) and share invoices as PDF files at their discretion. |
| **Data Deletion** | Users can delete individual records or uninstall the app to remove all data. |
| **Permissions** | Explanation of each permission requested and why (see [Section 4](#4-android-permissions)). |
| **Children's Privacy** | The app is not directed at children under 13. |
| **Contact Information** | Developer contact email for privacy inquiries. |

### TODO: Future Privacy Considerations

When future versions add cloud features, the privacy policy must be updated to disclose:

- [ ] TODO: Firebase Analytics data collection (if added)
- [ ] TODO: Firebase Crashlytics crash report data (if added)
- [ ] TODO: Firebase Authentication user identity data (if added)
- [ ] TODO: Cloud Firestore data storage location and encryption (if added)
- [ ] TODO: Any third-party SDK data collection

### Privacy Policy Hosting

| Option | Recommendation |
|---|---|
| **GitHub Pages** | Free, reliable, easy to update |
| **Firebase Hosting** | Free tier available, custom domain support |
| **Personal Website** | Full control |
| **Google Sites** | Free, simple |

- [ ] TODO: Choose hosting platform
- [ ] TODO: Publish privacy policy
- [ ] TODO: Add URL to Play Store listing
- [ ] TODO: Add URL to in-app Settings screen

---

## 3. Data Collection Disclosure

### Play Console Data Safety Form

Google Play requires a **Data Safety** form that discloses what data the app collects, shares, and how it's secured. For InvoiceFlow Pro V1:

#### Data Types — Collection Status

| Data Type | Collected? | Shared? | Required/Optional | Notes |
|---|---|---|---|---|
| **Name** | No | No | — | Customer names stored locally only |
| **Email** | No | No | — | Customer emails stored locally only |
| **Phone** | No | No | — | Customer phones stored locally only |
| **Address** | No | No | — | Customer/business addresses stored locally only |
| **Financial Info** | No | No | — | Invoice amounts stored locally only |
| **Photos** | No | No | — | Business logo stored locally only |
| **Files & Docs** | No | No | — | PDFs generated locally, user controls sharing |
| **App Activity** | No | No | — | No analytics in V1 |
| **Device Info** | No | No | — | Not collected in V1 |
| **Crash Logs** | No | No | — | TODO: Update if Crashlytics added |

> **Key Clarification for Google:** Data entered by the user (customer names, addresses, etc.) is stored **locally on the device only** and is **not transmitted** to any server. This is functionally equivalent to a note-taking app. The data exists solely on the user's device and is under the user's complete control.

#### Data Security Practices

| Practice | Status |
|---|---|
| Data encrypted in transit | N/A (no network transmission in V1) |
| Data encrypted at rest | TODO: Verify Isar encryption status |
| Users can request data deletion | Yes (delete records or uninstall) |
| Data deletion available on request | Yes (user-controlled) |

#### Form Guidance

When filling out the Data Safety form in Play Console:

1. **Does your app collect or share any of the required user data types?**
   → Select "No" for all categories (V1 does not transmit data off-device)

2. **Is all of the user data collected by your app encrypted in transit?**
   → N/A (no data transmitted)

3. **Do you provide a way for users to request that their data is deleted?**
   → Yes (users can delete individual records or uninstall the app)

> **Important:** Data stored locally on the user's device for app functionality is generally not considered "collected" under Google's Data Safety definition, as long as it is not transmitted to your servers. However, always review the latest Google Play Data Safety guidance.

---

## 4. Android Permissions

### Current Permissions

| Permission | Manifest Entry | Justification | Required? |
|---|---|---|---|
| **Storage (Read)** | TODO: Verify exact permission | Importing backup files, loading business logo | Conditional |
| **Storage (Write)** | TODO: Verify exact permission | Exporting PDF invoices, creating backup files | Conditional |
| **Camera** | TODO: Verify if used | Capturing business logo photo | Optional |

> **Note:** TODO: Audit `AndroidManifest.xml` for the complete list of declared permissions and verify each is necessary.

### Scoped Storage Strategy (Android 10+)

Starting with Android 10 (API 29), Android enforces **scoped storage**. InvoiceFlow Pro should handle this as follows:

| Operation | Strategy | API |
|---|---|---|
| **PDF Export** | Save to app-specific directory, then share via `Intent` | `getExternalFilesDir()` or `MediaStore` |
| **Backup Export** | Save to app-specific directory, then share or use SAF | `getExternalFilesDir()` or Storage Access Framework |
| **Backup Import** | Use SAF file picker to let user select backup file | Storage Access Framework |
| **Logo Import** | Use image picker or SAF | `image_picker` package or SAF |

### Permission Request Flow

```
User Action ──► Check Permission ──► Request if Needed ──► Handle Result
                                          │
                                    ┌─────┴─────┐
                                    │ Granted    │ Denied
                                    │            │
                                    ▼            ▼
                               Proceed    Show Explanation
                                          & Offer Settings
```

### Permission Best Practices

1. **Request at point of use** — Don't request permissions on app startup.
2. **Explain before requesting** — Show a dialog explaining why the permission is needed.
3. **Handle denial gracefully** — Provide alternative paths or explain how to enable in Settings.
4. **Minimize permissions** — Only request what is strictly necessary.
5. **Use scoped storage** — Avoid `MANAGE_EXTERNAL_STORAGE` unless absolutely required.

### Permission Justification (for Play Store Review)

If Google requests justification for any permission, provide:

| Permission | Justification Text |
|---|---|
| **Storage** | "InvoiceFlow Pro requires storage access to export PDF invoices to the device and to import/export backup files for data portability. All file operations use scoped storage APIs and the Storage Access Framework where supported." |
| **Camera** | "Camera access is optionally used to capture a business logo photo for inclusion on generated invoices. Users can alternatively select an existing image from their gallery." |

---

## 5. Release Build Checklist

### Pre-Build Verification

- [ ] All debug logging disabled or gated behind debug flag
- [ ] No hardcoded test data or mock data in production code
- [ ] `pubspec.yaml` version and build number updated
- [ ] All `// TODO` items in critical paths addressed
- [ ] All generated files are up to date (`build_runner`, `gen-l10n`)

### Build Configuration

#### Release Mode Testing

```bash
# Test in release mode before building final artifact
flutter run --release
```

Verify:
- [ ] App launches without crashes
- [ ] All screens render correctly
- [ ] No debug banners visible
- [ ] Performance is acceptable (no jank)
- [ ] PDF generation works in release mode
- [ ] Database operations work in release mode

#### Obfuscation Testing

```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

Verify:
- [ ] App launches without crashes after obfuscation
- [ ] All reflection-based features work (DI, database)
- [ ] PDF generation works after obfuscation
- [ ] No runtime `NoSuchMethodError` or `MissingPluginException`

#### minifyEnabled / R8 Testing

The `android/app/build.gradle` should have:

```groovy
// TODO: Verify exact build.gradle configuration
buildTypes {
    release {
        signingConfig signingConfigs.release  // TODO: Configure signing
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

Verify:
- [ ] App compiles with `minifyEnabled true`
- [ ] No runtime crashes caused by code stripping
- [ ] All packages with reflection have proper keep rules

#### AAB Validation

```bash
# Build the App Bundle
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# Validate using bundletool (optional but recommended)
# Download bundletool from https://github.com/google/bundletool
java -jar bundletool.jar validate --bundle=build/app/outputs/bundle/release/app-release.aab
```

- [ ] AAB file size is acceptable (target < 25MB)
- [ ] AAB uploads to Play Console without errors
- [ ] Play Console shows correct version code and name

### App Signing

| Item | Status |
|---|---|
| Upload keystore generated | TODO |
| Keystore stored securely (not in repo) | TODO |
| `key.properties` configured | TODO |
| Play App Signing enrolled | TODO |
| Signing config in `build.gradle` | TODO |

> **Critical:** Never commit your keystore or `key.properties` to version control. Add them to `.gitignore`.

---

## 6. ProGuard / R8 Notes

### Overview

R8 is the default code shrinker for Android. It replaces ProGuard and handles:
- **Code shrinking** — Removes unused code
- **Obfuscation** — Renames classes/methods
- **Optimization** — Optimizes bytecode

### Required Keep Rules

Create or update `android/app/proguard-rules.pro`:

```proguard
# TODO: Verify and update these rules based on actual dependencies

# ── Isar Database ──
# Isar uses native libraries and reflection
-keep class dev.isar.** { *; }
-keep class io.isar.** { *; }
# TODO: Verify exact Isar ProGuard rules from Isar documentation

# ── PDF Generation ──
# TODO: Add keep rules if the PDF package uses reflection
# -keep class <pdf_package>.** { *; }

# ── Flutter ──
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ── Kotlin ──
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# ── General ──
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# ── TODO: Add rules for any additional packages that use reflection ──
```

### Testing R8 Compatibility

After adding keep rules:

1. Build release APK: `flutter build apk --release`
2. Install on physical device
3. Test every screen and feature
4. Pay special attention to:
   - [ ] Database read/write operations
   - [ ] PDF generation and export
   - [ ] Dependency injection (GetIt)
   - [ ] JSON serialization/deserialization
   - [ ] Backup/restore functionality

### Debugging R8 Issues

```bash
# If R8 strips necessary code, check the mapping file:
# build/app/outputs/mapping/release/mapping.txt

# To temporarily disable R8 for debugging:
# In android/app/build.gradle, set:
# minifyEnabled false
# shrinkResources false
```

---

## 7. Play Store Assets

### Required Assets Checklist

| Asset | Specification | Status |
|---|---|---|
| **App Icon** | 512 × 512 px, PNG, 32-bit, no alpha | TODO |
| **Feature Graphic** | 1024 × 500 px, PNG or JPEG | TODO |
| **Phone Screenshots** | Min 2, max 8, 16:9 or 9:16, JPEG/PNG | TODO |
| **Tablet Screenshots** | Optional but recommended, 16:9 or 9:16 | TODO |
| **Short Description** | Max 80 characters | TODO |
| **Full Description** | Max 4000 characters | TODO |
| **Privacy Policy URL** | Must be publicly accessible | TODO |
| **App Category** | Business | Set |
| **Contact Email** | Required | TODO |
| **Contact Phone** | Optional | TODO |
| **Contact Website** | Optional | TODO |

### App Icon Requirements

- 512 × 512 pixels
- 32-bit PNG (with alpha)
- Must follow [Google's icon guidelines](https://developer.android.com/distribute/google-play/resources/icon-design-specifications)
- No badges, text overlays, or device frames
- Must be recognizable at small sizes (24 × 24 dp)

### Screenshot Best Practices

| Guideline | Detail |
|---|---|
| Show real app content | Use realistic demo data, not "Lorem ipsum" |
| Highlight key features | Dashboard, invoice creation, PDF preview |
| Use consistent framing | Same device frame style (or no frames) |
| Add captions | Brief text overlay explaining each screen |
| Show diversity | Different screens, not variations of one |
| Language | English for primary listing |
| Order | Most impactful screenshot first |

### Recommended Screenshots (6–8)

1. Dashboard with summary statistics
2. Invoice creation flow
3. PDF invoice preview
4. Customer management
5. Business profile setup
6. Multi-language support showcase
7. Backup & restore feature
8. Settings / theme customization

### Short Description Template

```
TODO: Write compelling 80-character description
Example: "Create professional invoices offline. PDF export, multilingual, free."
```

### Full Description Template

```
TODO: Write keyword-rich 4000-character description covering:
- App introduction (what it does)
- Key features (bulleted list)
- Target audience
- Language support
- Offline capability
- Data safety
- Call to action
```

---

## 8. Content Rating

### IARC Rating Questionnaire

InvoiceFlow Pro is a business/productivity app with no objectionable content.

| Question Area | Expected Answer |
|---|---|
| **Violence** | None |
| **Sexual Content** | None |
| **Language** | None |
| **Controlled Substances** | None |
| **Gambling** | None |
| **User-Generated Content** | No (user data is private/local) |
| **Social Features** | No |
| **In-App Purchases** | TODO: Update if premium tier added |
| **Ads** | No (not recommended for V1) |

### Expected Rating

| Rating Body | Expected Rating |
|---|---|
| **ESRB** | Everyone |
| **PEGI** | 3 |
| **USK** | 0 |
| **IARC** | 3+ |

### Target Audience Declaration

| Setting | Value |
|---|---|
| **Target Age Group** | 18+ (business users) |
| **Appeals to Children** | No |
| **Complies with Families Policy** | N/A (not targeting children) |

> **Important:** Do not select target audiences under 18 unless the app genuinely serves that demographic. Selecting younger audiences triggers additional Families Policy requirements.

---

## 9. Monetization Strategy

### V1 — Free Release

| Aspect | Decision |
|---|---|
| **Price** | Free |
| **In-App Purchases** | None in V1 |
| **Ads** | Not recommended (see below) |
| **Premium Features** | TODO: Define for V2 |

### Why No Ads in V1

| Reason | Detail |
|---|---|
| **Professional Image** | Business users expect ad-free tools |
| **User Trust** | Ads undermine trust in a financial/invoicing app |
| **Privacy** | Ad SDKs collect data, complicating the privacy story |
| **UX Quality** | Ads degrade the user experience |
| **Revenue Model** | Freemium conversion is more sustainable for business apps |

### Future Monetization (V2+)

#### Freemium Model (Recommended)

| Tier | Price | Features |
|---|---|---|
| **Free** | $0 | Core invoicing, limited templates, local storage |
| **Pro** | TODO: Define | Unlimited invoices, all templates, cloud sync |
| **Business** | TODO: Define | Multi-user, advanced reports, priority support |

#### In-App Purchase Implementation

- [ ] TODO: Define premium feature gates
- [ ] TODO: Choose payment provider (Google Play Billing Library)
- [ ] TODO: Implement purchase flow
- [ ] TODO: Implement purchase restoration
- [ ] TODO: Handle subscription lifecycle

#### CodeCanyon Revenue

- One-time source code sales
- Extended license for SaaS/resale use cases
- See [CodeCanyon Setup Guide](codecanyon_setup_guide.md) for details

### Monetization Compliance

| Requirement | Status |
|---|---|
| Play Billing Library for digital goods | TODO (V2) |
| No alternative payment methods for digital content | Acknowledged |
| Subscription cancellation must be straightforward | TODO (V2) |
| Free trial terms clearly stated | TODO (V2) |
| Price displayed before purchase | TODO (V2) |

---

## 10. Post-Launch Monitoring

### Crash Monitoring

#### Firebase Crashlytics (Recommended)

| Item | Status |
|---|---|
| Crashlytics SDK integrated | TODO |
| Non-fatal error reporting | TODO |
| Custom crash keys (user context) | TODO |
| Obfuscation mapping file uploaded | TODO |
| Alert thresholds configured | TODO |

```yaml
# TODO: Add to pubspec.yaml when ready
# firebase_crashlytics: ^X.X.X
# firebase_core: ^X.X.X
```

#### Crash Monitoring Targets

| Metric | Target | Action if Exceeded |
|---|---|---|
| **Crash-free users** | ≥ 99.5% | Hotfix release |
| **Crash-free sessions** | ≥ 99.9% | Investigate within 24h |
| **ANR rate** | < 0.47% | Performance investigation |

### Analytics (Placeholder)

| Item | Status |
|---|---|
| Firebase Analytics integrated | TODO |
| Key events defined | TODO |
| Conversion funnels configured | TODO |
| User properties set | TODO |

#### Recommended Analytics Events

| Event | Trigger |
|---|---|
| `invoice_created` | User creates a new invoice |
| `pdf_exported` | User exports/shares a PDF |
| `customer_added` | User adds a new customer |
| `backup_created` | User creates a backup |
| `backup_restored` | User restores from backup |
| `language_changed` | User changes app language |
| `theme_changed` | User switches light/dark mode |

> **Privacy Note:** If analytics are implemented, the privacy policy and data safety form must be updated to disclose data collection.

### Review Monitoring

| Activity | Frequency | Owner |
|---|---|---|
| Check new Play Store reviews | Daily (first week), then 2x/week | TODO |
| Respond to 1–2 star reviews | Within 24 hours | TODO |
| Respond to feature requests | Within 48 hours | TODO |
| Compile feedback themes | Weekly | TODO |
| Update roadmap based on feedback | Bi-weekly | TODO |

### Review Response Templates

**For bug reports (1–2 stars):**
> Thank you for your feedback! We're sorry you experienced this issue. We've noted the problem and are working on a fix. Could you please email us at [TODO: email] with more details? We'd love to help resolve this for you.

**For feature requests:**
> Thank you for the suggestion! We're actively developing InvoiceFlow Pro and your feedback helps us prioritize. We've added this to our roadmap for consideration.

**For positive reviews (4–5 stars):**
> Thank you so much for the kind words! We're glad InvoiceFlow Pro is helping your business. If you have any suggestions for improvement, we'd love to hear them!

### Staged Rollout Monitoring

| Stage | % Users | Duration | Gate Criteria |
|---|---|---|---|
| Stage 1 | 10% | 24 hours | Crash-free ≥ 99.5%, no P0 bugs |
| Stage 2 | 25% | 24 hours | Crash-free ≥ 99.5%, no P0 bugs |
| Stage 3 | 50% | 24 hours | Crash-free ≥ 99.5%, no P0 bugs |
| Stage 4 | 100% | — | All metrics stable |

**Rollback Criteria:**
- Crash-free rate drops below 99%
- P0 bug reported by 3+ users
- Data loss reported by any user
- ANR rate exceeds 1%

### Post-Launch Timeline

| Timeframe | Activities |
|---|---|
| **Day 1–2** | Intensive crash/ANR monitoring, respond to all reviews |
| **Day 3–7** | Continue monitoring, advance staged rollout |
| **Week 2** | Compile feedback report, plan v1.1.0 hotfix if needed |
| **Week 3–4** | Begin v1.1.0 development based on feedback |
| **Month 2** | v1.1.0 release (polish & bug fixes) |

---

> _This compliance guide must be reviewed and updated before every production release. Stay current with Google Play policy changes at [Google Play Policy Center](https://play.google.com/about/developer-content-policy/)._
