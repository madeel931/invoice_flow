# InvoiceFlow Pro — Play Store Release Checklist

> **Product Owner:** ADii Labs  
> **Last Updated:** 2026-05-27  
> **Target Version:** v1.0.0

---

## How to Use This Checklist

Complete every item before submitting to the Play Store. Mark items with:
- `[x]` — Completed and verified
- `[ ]` — Not yet done
- `[N/A]` — Not applicable for this release

---

## 1. App Stability

- [ ] All screens load without crashes
- [ ] No ANR (Application Not Responding) issues
- [ ] Memory usage is within acceptable limits (< 150MB peak)
- [ ] No memory leaks detected (test with DevTools)
- [ ] App handles low-memory conditions gracefully
- [ ] App recovers from process death correctly
- [ ] All navigation flows work without errors
- [ ] Back button behavior is correct on all screens
- [ ] App handles rotation/orientation changes (if supported)
- [ ] No unhandled exceptions in release mode
- [ ] Firebase Crashlytics (or equivalent) integrated and reporting
- [ ] Tested on minimum 3 physical devices
- [ ] Tested on Android 5.0 (API 21) emulator
- [ ] Tested on latest Android version

---

## 2. Localization

- [ ] English (en) — all strings complete and reviewed
- [ ] Arabic (ar) — all strings complete and reviewed
- [ ] Urdu (ur) — all strings complete and reviewed
- [ ] RTL layout renders correctly for Arabic
- [ ] RTL layout renders correctly for Urdu
- [ ] No hardcoded strings in UI code
- [ ] Date formats respect locale
- [ ] Number formats respect locale
- [ ] Currency symbols display correctly per locale
- [ ] App name is localized in launcher
- [ ] No text overflow/clipping in any language

---

## 3. PDF Testing

- [ ] PDF generates successfully for all languages (EN, AR, UR)
- [ ] PDF opens correctly in major PDF readers (Google Drive, Adobe)
- [ ] Company logo renders at correct resolution
- [ ] Long customer names don't overflow
- [ ] Long item names wrap correctly
- [ ] Large amounts display correctly (10,000,000+)
- [ ] Tax calculations are accurate on PDF
- [ ] Discount calculations are accurate on PDF
- [ ] Grand total matches line item sum
- [ ] Multi-page invoices paginate correctly
- [ ] Currency symbols align correctly
- [ ] Arabic/Urdu text renders with correct font
- [ ] PDF file size is reasonable (< 2MB for typical invoice)
- [ ] Share/export PDF works via all share targets

→ See also: [PDF Engine Audit](../testing/pdf_engine_audit.md)

---

## 4. Backup & Restore

- [ ] Full backup exports all data (invoices, customers, items, settings)
- [ ] Backup file is valid JSON and parseable
- [ ] Restore on fresh install works correctly
- [ ] Restore on existing data prompts user (merge vs. replace)
- [ ] Backup file size is reasonable
- [ ] Backup includes app version metadata
- [ ] Restore validates backup file version compatibility
- [ ] Corrupted backup file shows user-friendly error
- [ ] Backup/restore works with large datasets (500+ invoices)
- [ ] Share backup via email/messaging works

---

## 5. Privacy Policy

- [ ] Privacy policy written and reviewed
- [ ] Privacy policy hosted at accessible URL
- [ ] Privacy policy URL added to Play Store listing
- [ ] Privacy policy URL accessible from within the app (Settings)
- [ ] Data collection disclosures are accurate
- [ ] Data safety form completed in Play Console
- [ ] No unnecessary permissions requested
- [ ] Permissions declared in manifest match actual usage

---

## 6. App Icon

- [ ] App icon follows Material Design guidelines
- [ ] Icon is clear and recognizable at small sizes
- [ ] Adaptive icon configured (foreground + background layers)
- [ ] Icon renders correctly on all launcher shapes (circle, squircle, square)
- [ ] No visual artifacts or clipping
- [ ] Icon is distinct from competitors
- [ ] Icon assets generated for all required densities

---

## 7. Screenshots

- [ ] Minimum 2 screenshots (recommended 6–8)
- [ ] Screenshots show actual app UI (not mockups)
- [ ] Screenshots highlight key features:
  - [ ] Dashboard
  - [ ] Invoice creation
  - [ ] PDF preview
  - [ ] Customer management
  - [ ] Settings/Business profile
- [ ] Screenshots prepared for phone form factor
- [ ] Screenshots have consistent framing and style
- [ ] Text overlays (if any) are in English
- [ ] TODO: Prepare localized screenshots for AR/UR listings

---

## 8. Feature Graphic

- [ ] Feature graphic dimensions: 1024 × 500 px
- [ ] Graphic clearly communicates app purpose
- [ ] ADii Labs branding included (subtle)
- [ ] Text is legible at small sizes
- [ ] No excessive text (Play Store guideline)
- [ ] Graphic looks good on both light and dark backgrounds

---

## 9. Play Store Listing

- [ ] App title: InvoiceFlow Pro — Invoice Maker & PDF Generator
- [ ] Short description written (max 80 characters)
- [ ] Full description written (max 4000 characters)
- [ ] Description includes relevant keywords
- [ ] Contact email address set
- [ ] App category: Business → Finance
- [ ] Content rating questionnaire completed
- [ ] Target audience and content settings configured
- [ ] App is not marked as containing ads (unless it does)
- [ ] TODO: Prepare localized listing for Arabic
- [ ] TODO: Prepare localized listing for Urdu

---

## 10. Release Build

- [ ] Version code incremented in `pubspec.yaml`
- [ ] Version name matches planned release (e.g., 1.0.0)
- [ ] Release build compiles without errors
- [ ] ProGuard/R8 rules configured correctly (no runtime crashes)
- [ ] App signing configured with upload key
- [ ] APK/AAB size is acceptable (target < 25MB)
- [ ] `flutter build appbundle --release` succeeds
- [ ] Debug logging disabled in release build
- [ ] No debug banners or developer tools exposed
- [ ] Performance profiled in release mode

---

## 11. Internal Testing

- [ ] Internal testing track created in Play Console
- [ ] APK/AAB uploaded to internal testing
- [ ] Minimum 10 internal testers invited
- [ ] All testers have completed at least one full workflow:
  - [ ] Create business profile
  - [ ] Add a customer
  - [ ] Add items/products
  - [ ] Create an invoice
  - [ ] Generate and share PDF
  - [ ] Perform backup and restore
- [ ] 14-day testing period completed
- [ ] All critical bugs from testing resolved
- [ ] Feedback collected and documented

---

## 12. Staged Rollout

- [ ] Production release created in Play Console
- [ ] Staged rollout configured:
  - [ ] Stage 1: 10% of users
  - [ ] Stage 2: 25% of users (after 24h if stable)
  - [ ] Stage 3: 50% of users (after 24h if stable)
  - [ ] Stage 4: 100% of users (after 24h if stable)
- [ ] Rollback plan documented
- [ ] Previous stable version available for emergency rollback

---

## 13. Post-Launch Monitoring

### First 24 Hours
- [ ] Monitor crash reports (Crashlytics)
- [ ] Monitor Play Store reviews
- [ ] Monitor ANR rate (target < 0.47%)
- [ ] Monitor crash rate (target < 1.09%)
- [ ] Check install/uninstall ratio

### First 48 Hours
- [ ] Respond to any 1-star reviews
- [ ] Verify no critical bugs reported
- [ ] Confirm staged rollout progression is safe
- [ ] Document any issues for v1.1.0

### First Week
- [ ] Compile user feedback summary
- [ ] Prioritize bug fixes for v1.1.0
- [ ] Update roadmap based on user feedback
- [ ] Celebrate the launch! 🎉

---

## Sign-Off

| Role | Name | Date | Approved |
|---|---|---|---|
| Developer | TODO | TODO | [ ] |
| QA Tester | TODO | TODO | [ ] |
| Product Owner | TODO | TODO | [ ] |

---

> _This checklist must be completed in full before any production release of InvoiceFlow Pro._
