# InvoiceFlow Pro — Testing Strategy

> **Product:** InvoiceFlow Pro  
> **Developer:** ADii Labs  
> **Document Version:** 1.0  
> **Last Updated:** 2026-05-27

---

## Table of Contents

1. [Testing Philosophy](#1-testing-philosophy)
2. [Current Testing Scope](#2-current-testing-scope)
3. [Recommended Future Tests](#3-recommended-future-tests)
4. [Critical Business Logic Testing](#4-critical-business-logic-testing)
5. [UI Testing Areas](#5-ui-testing-areas)
6. [Release Testing Checklist](#6-release-testing-checklist)

---

## 1. Testing Philosophy

### Core Principles

InvoiceFlow Pro is a **business-critical application** that handles financial data. Testing must prioritize:

| Priority | Principle | Rationale |
|---|---|---|
| **P0** | **Production Stability** | The app must never crash during normal business operations. A crash during invoice creation or PDF export destroys user trust. |
| **P1** | **Business Data Safety** | Invoice data, customer records, and financial calculations must be 100% accurate. Data loss or calculation errors have real financial consequences. |
| **P2** | **Offline-First Reliability** | Every feature must work without network connectivity. The app cannot degrade, show errors, or stall due to missing internet. |
| **P3** | **Cross-Language Correctness** | English, Arabic, and Urdu layouts must render correctly with no overflow, clipping, or misalignment. RTL support must be complete. |
| **P4** | **PDF Output Quality** | Generated invoices must be professional-quality, correctly formatted, and accurate across all supported languages and edge cases. |

### Testing Mindset

> _"If a bug can cause a user to lose money, lose data, or lose trust — it is a P0 bug."_

The testing strategy is designed around these scenarios:
- **Worst case:** User generates an invoice with wrong totals and sends it to a client.
- **Bad case:** User loses all data because backup/restore fails silently.
- **Unacceptable case:** App crashes during a critical workflow (invoice creation, PDF export).

---

## 2. Current Testing Scope

### V1 Testing Approach: Manual Testing

For the V1 release, testing is primarily **manual** with structured checklists. This is appropriate because:

1. The app is in active development with frequent UI changes
2. Manual testing catches visual/UX issues that automated tests miss
3. The team size is small, and manual testing is more time-efficient at this stage
4. Structured audit documents provide traceability

### Manual Testing Documents

| Document | Purpose | Link |
|---|---|---|
| **v1 Bug Audit** | Screen-by-screen bug tracking | [v1_bug_audit.md](v1_bug_audit.md) |
| **PDF Engine Audit** | 82-point PDF generation test suite | [pdf_engine_audit.md](pdf_engine_audit.md) |
| **Play Store Release Checklist** | Pre-release verification | [playstore_release_checklist.md](../release/playstore_release_checklist.md) |

### Current Coverage

| Area | Testing Method | Coverage |
|---|---|---|
| Dashboard | Manual | TODO: Complete audit |
| Customers CRUD | Manual | TODO: Complete audit |
| Invoices CRUD | Manual | TODO: Complete audit |
| Items/Products CRUD | Manual | TODO: Complete audit |
| Settings | Manual | TODO: Complete audit |
| Business Profile | Manual | TODO: Complete audit |
| PDF Generation | Manual (82-point audit) | TODO: Complete audit |
| Backup/Restore | Manual | TODO: Complete audit |
| Localization (EN) | Manual | TODO: Complete audit |
| Localization (AR) | Manual | TODO: Complete audit |
| Localization (UR) | Manual | TODO: Complete audit |
| Navigation Flows | Manual | TODO: Complete audit |

### Automated Testing (Current State)

| Test Type | Status | File Location |
|---|---|---|
| Unit Tests | TODO: Assess current coverage | `test/` |
| Widget Tests | TODO: Assess current coverage | `test/` |
| Integration Tests | TODO: Assess current coverage | `integration_test/` |

> **TODO:** Run `flutter test --coverage` to assess current automated test coverage and document results here.

---

## 3. Recommended Future Tests

### Testing Pyramid

```
          ┌────────────┐
          │   E2E /     │    Few, expensive, high-confidence
          │ Integration │
          ├────────────┤
          │   Widget    │    Moderate, test UI components
          │   Tests     │
          ├────────────┤
          │   Unit      │    Many, fast, test business logic
          │   Tests     │
          └────────────┘
```

### Unit Tests (Highest Priority)

Unit tests should cover the **Domain** and **Data** layers — pure Dart logic with no Flutter framework dependency.

| Target | What to Test | Priority |
|---|---|---|
| **Invoice Calculations** | Subtotal, tax, discount, grand total | P0 |
| **Use Cases** | Each use case returns expected results | P1 |
| **Repository Implementations** | CRUD operations return correct data | P1 |
| **Data Models** | `toJson` / `fromJson` serialization | P1 |
| **Validators** | Input validation logic | P2 |
| **Formatters** | Currency, date, number formatting | P2 |
| **Backup Serialization** | Export/import data integrity | P1 |

#### Recommended Unit Test Structure

```
test/
├── features/
│   ├── customers/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── customer_model_test.dart
│   │   │   └── repositories/
│   │   │       └── customer_repository_impl_test.dart
│   │   └── domain/
│   │       └── use_cases/
│   │           ├── get_all_customers_test.dart
│   │           └── add_customer_test.dart
│   │
│   ├── invoices/
│   │   ├── data/
│   │   └── domain/
│   │       └── use_cases/
│   │           └── calculate_invoice_totals_test.dart  ◄── CRITICAL
│   │
│   └── ...
│
├── core/
│   ├── utils/
│   │   ├── currency_formatter_test.dart
│   │   ├── date_formatter_test.dart
│   │   └── validators_test.dart
│   └── ...
│
└── test_helpers/
    ├── mocks.dart
    └── fixtures.dart
```

### Widget Tests (Medium Priority)

Widget tests verify individual UI components render correctly and respond to user interaction.

| Target | What to Test | Priority |
|---|---|---|
| **Invoice Form** | Field validation, item addition, total display | P1 |
| **Customer Form** | Required fields, save behavior | P2 |
| **Item Form** | Price/quantity input, validation | P2 |
| **Settings Screen** | Language switch, currency switch | P2 |
| **Dashboard Cards** | Correct data display | P2 |
| **PDF Preview** | Renders without error | P2 |

### Integration Tests (Lower Priority for V1)

Integration tests verify complete user flows from start to finish.

| Flow | What to Test | Priority |
|---|---|---|
| **Create Invoice Flow** | Select customer → Add items → Review → Save → Export PDF | P1 |
| **Backup/Restore Cycle** | Create data → Backup → Clear data → Restore → Verify | P1 |
| **Onboarding Flow** | First launch → Business profile → First invoice | P2 |
| **Full CRUD Cycle** | Create → Read → Update → Delete for each entity | P2 |

#### Integration Test Structure

```
integration_test/
├── create_invoice_flow_test.dart
├── backup_restore_flow_test.dart
├── customer_crud_test.dart
└── test_helpers/
    └── test_data.dart
```

### Running Tests

```bash
# Run all unit and widget tests
flutter test

# Run with coverage
flutter test --coverage

# Run a specific test file
flutter test test/features/invoices/domain/use_cases/calculate_invoice_totals_test.dart

# Run integration tests (requires connected device/emulator)
flutter test integration_test/

# Generate coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 4. Critical Business Logic Testing

### Invoice Calculations (P0 — Must Test)

Invoice calculations are the most critical business logic. Errors here directly impact users financially.

#### Subtotal Calculation

| Test Case | Input | Expected Output |
|---|---|---|
| Single item | qty: 1, price: 100.00 | 100.00 |
| Multiple quantity | qty: 5, price: 25.00 | 125.00 |
| Multiple items | item1: 100, item2: 200 | 300.00 |
| Zero quantity | qty: 0, price: 50.00 | 0.00 |
| Decimal prices | qty: 3, price: 33.33 | 99.99 |
| Large amounts | qty: 1000, price: 99999.99 | 99,999,990.00 |

#### Tax Calculation

| Test Case | Subtotal | Tax Rate | Expected Tax | Expected Total |
|---|---|---|---|---|
| No tax | 1000.00 | 0% | 0.00 | 1000.00 |
| Standard tax | 1000.00 | 5% | 50.00 | 1050.00 |
| High tax | 1000.00 | 15% | 150.00 | 1150.00 |
| Rounding case | 33.33 | 7% | 2.33 | 35.66 |

#### Discount Calculation

| Test Case | Subtotal | Discount | Expected Discount | Expected Total |
|---|---|---|---|---|
| No discount | 1000.00 | 0% | 0.00 | 1000.00 |
| Percentage discount | 1000.00 | 10% | 100.00 | 900.00 |
| Fixed discount | 1000.00 | $50 fixed | 50.00 | 950.00 |
| 100% discount | 1000.00 | 100% | 1000.00 | 0.00 |

#### Combined Tax + Discount

| Test Case | Subtotal | Discount | Tax Rate | Expected Total |
|---|---|---|---|---|
| Discount then tax | 1000.00 | 10% | 5% | 945.00 |
| Tax then discount | TODO: Define order | TODO | TODO | TODO |
| Both zero | 1000.00 | 0% | 0% | 1000.00 |

> **Critical:** TODO: Verify the actual order of operations (discount before tax vs. tax before discount) in the codebase. This must be consistent and documented.

### Totals Accuracy

| Test Case | Description | Verification |
|---|---|---|
| Rounding consistency | All amounts rounded to 2 decimal places | Manual + Unit test |
| Large invoice (50+ items) | Sum of line totals matches displayed subtotal | Manual + Unit test |
| Currency-specific formatting | Correct decimal separator for locale | Manual |
| Zero invoice | All items with zero amount | Edge case test |

### PDF Generation

| Test Case | Description | Priority |
|---|---|---|
| PDF matches screen data | All values on PDF match the invoice preview | P0 |
| PDF totals accuracy | Totals on PDF match calculated totals | P0 |
| PDF language rendering | Correct font and direction per language | P0 |
| PDF file integrity | Generated PDF opens without corruption | P0 |

→ See [PDF Engine Audit](pdf_engine_audit.md) for the complete 82-point test suite.

### Backup Data Integrity

| Test Case | Description | Priority |
|---|---|---|
| Full backup completeness | All entities included in backup file | P0 |
| Restore accuracy | Restored data matches original exactly | P0 |
| Version compatibility | Backup from version N restores on version N+1 | P1 |
| Corrupted file handling | App shows error, does not crash | P1 |
| Large dataset backup | 500+ invoices, 200+ customers | P1 |

---

## 5. UI Testing Areas

### Localization Testing

| Test Area | EN | AR | UR | Notes |
|---|---|---|---|---|
| All strings translated | TODO | TODO | TODO | No untranslated strings |
| No text overflow | TODO | TODO | TODO | All text fits containers |
| No text clipping | TODO | TODO | TODO | No truncated content |
| Correct text direction | LTR ✓ | RTL TODO | RTL TODO | Verify layout mirrors |
| Date format | TODO | TODO | TODO | Locale-appropriate |
| Number format | TODO | TODO | TODO | Locale-appropriate |
| Currency format | TODO | TODO | TODO | Locale-appropriate |
| App title localized | TODO | TODO | TODO | Launcher label |

### RTL Layout Testing

| Screen | Mirrors Correctly? | Notes |
|---|---|---|
| Dashboard | TODO | Cards, stats, navigation |
| Customer List | TODO | List items, FAB position |
| Customer Form | TODO | Labels, inputs, buttons |
| Invoice List | TODO | List items, status badges |
| Invoice Form | TODO | Complex layout with items table |
| Item List | TODO | List items, prices |
| Item Form | TODO | Labels, inputs |
| Settings | TODO | Toggle switches, selections |
| Business Profile | TODO | Logo position, form fields |
| PDF Preview | TODO | PDF content direction |

### Responsiveness Testing

| Screen Width | Status | Notes |
|---|---|---|
| 320dp (small phone) | TODO | Minimum supported width |
| 360dp (standard phone) | TODO | Most common |
| 400dp (large phone) | TODO | |
| 420dp (extra large phone) | TODO | |
| 600dp (small tablet) | TODO | If tablet support planned |
| 800dp (tablet) | TODO | If tablet support planned |

### Overflow Handling

| Test Case | Screen | Expected Behavior | Status |
|---|---|---|---|
| Very long customer name | Customer list | Truncate with ellipsis | TODO |
| Very long invoice number | Invoice list | Truncate or wrap | TODO |
| Many decimal places | Invoice form | Round to 2 decimals | TODO |
| Large amount in dashboard | Dashboard | Format with abbreviation or scroll | TODO |
| Long item description | Invoice form | Wrap within container | TODO |
| Empty state | All list screens | Show placeholder illustration | TODO |

---

## 6. Release Testing Checklist

### Pre-Release APK Testing

Every release candidate APK must pass these tests on at least one physical device:

#### Core Functionality

- [ ] App launches without crash (cold start)
- [ ] App launches without crash (warm start)
- [ ] Dashboard displays correct summary statistics
- [ ] Create new customer → verify saved
- [ ] Edit existing customer → verify updated
- [ ] Delete customer → verify removed
- [ ] Create new item/product → verify saved
- [ ] Edit existing item → verify updated
- [ ] Delete item → verify removed
- [ ] Create new invoice with 1 line item → verify saved
- [ ] Create new invoice with 5+ line items → verify saved
- [ ] Edit existing invoice → verify updated
- [ ] Delete invoice → verify removed
- [ ] Generate PDF from invoice → verify opens correctly
- [ ] Share PDF via share sheet → verify sharing works
- [ ] Set up business profile → verify saved
- [ ] Change language to Arabic → verify UI switches to RTL
- [ ] Change language to Urdu → verify UI switches to RTL
- [ ] Change language back to English → verify UI switches to LTR
- [ ] Change currency → verify updates across app
- [ ] Toggle dark mode → verify theme switches
- [ ] Navigate to every screen → verify no crashes

#### Update Testing

- [ ] Install previous version
- [ ] Add test data (5 customers, 10 items, 5 invoices)
- [ ] Install new version over previous (update)
- [ ] Verify all existing data is preserved
- [ ] Verify app launches without migration errors
- [ ] Verify all features work with migrated data

#### Backup/Restore Testing

- [ ] Create backup with existing data → verify file is created
- [ ] Share backup file → verify it can be transferred
- [ ] Fresh install on another device/emulator
- [ ] Import backup file → verify all data restored
- [ ] Verify restored data matches original:
  - [ ] Customer count matches
  - [ ] Item count matches
  - [ ] Invoice count matches
  - [ ] Invoice totals match
  - [ ] Business profile matches
  - [ ] Settings match

#### Edge Cases

- [ ] Launch with no data → verify empty states
- [ ] Create invoice with no customer → verify validation
- [ ] Create invoice with no items → verify validation
- [ ] Rotate device (if supported) → verify no crash
- [ ] Background app for 30 minutes → resume → verify state preserved
- [ ] Kill app process → relaunch → verify data preserved
- [ ] Low storage warning → verify graceful handling

#### Performance

- [ ] Cold start time < 3 seconds (mid-range device)
- [ ] List scrolling is smooth (60fps)
- [ ] PDF generation completes in < 5 seconds
- [ ] No ANR warnings during any operation
- [ ] Memory usage stays below 150MB

### Test Report Template

After completing testing, document results:

```markdown
## Release Test Report

**Version:** v[X.Y.Z]
**Date:** [YYYY-MM-DD]
**Tester:** [Name]
**Device:** [Model, Android version]
**Build:** [Release / Debug]

### Results Summary
- Total tests: [N]
- Passed: [N]
- Failed: [N]
- Blocked: [N]

### Failed Tests
| # | Test | Expected | Actual | Severity |
|---|---|---|---|---|

### Notes
[Any observations, risks, or recommendations]

### Recommendation
- [ ] Approve for release
- [ ] Block release (fix required)
```

---

## Appendix: Test Data Sets

### Recommended Test Data

For consistent manual testing, maintain standard test datasets:

| Dataset | Purpose |
|---|---|
| **Minimal** | 1 customer, 1 item, 1 invoice — basic smoke test |
| **Standard** | 10 customers, 20 items, 15 invoices — typical usage |
| **Stress** | 200 customers, 500 items, 500 invoices — performance test |
| **Edge Case** | Long names, large amounts, special characters |
| **Multilingual** | Mix of EN, AR, UR data in all fields |

> **TODO:** Create standardized test data JSON files that can be imported via the backup/restore feature for reproducible testing.

---

> _This testing strategy should be reviewed and updated before each major release. As the project matures, automated test coverage should increase to reduce manual testing burden._
