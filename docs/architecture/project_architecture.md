# InvoiceFlow Pro — Project Architecture

> **Product Owner:** ADii Labs  
> **Last Updated:** 2026-05-27

---

## 1. Clean Architecture Overview

InvoiceFlow Pro follows **Clean Architecture** principles with a **feature-based folder structure**. This ensures separation of concerns, testability, and scalability.

```
┌─────────────────────────────────────────┐
│              Presentation               │
│         (UI, Widgets, Cubits)           │
├─────────────────────────────────────────┤
│               Domain                    │
│      (Entities, Use Cases, Repos)       │
├─────────────────────────────────────────┤
│                Data                     │
│    (Models, Data Sources, Repo Impl)    │
├─────────────────────────────────────────┤
│                Core                     │
│   (Utils, Constants, DI, Extensions)    │
└─────────────────────────────────────────┘
```

### Key Principles
- **Dependency Rule:** Inner layers must not depend on outer layers.
- **Feature Isolation:** Each feature is self-contained with its own layers.
- **Abstraction:** Repository interfaces live in Domain; implementations live in Data.
- **Testability:** Business logic (Use Cases, Cubits) can be tested without UI or database.

---

## 2. Feature-Based Folder Structure

```
lib/
├── app/                          # App-level configuration
│   ├── app.dart                  # MaterialApp setup
│   ├── routes.dart               # Route definitions
│   └── theme/                    # Theme configuration
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_text_styles.dart
│
├── core/                         # Shared utilities & infrastructure
│   ├── constants/                # App-wide constants
│   ├── di/                       # Dependency injection setup
│   ├── error/                    # Error handling (Failures, Exceptions)
│   ├── extensions/               # Dart/Flutter extensions
│   ├── network/                  # Network utilities (if applicable)
│   ├── utils/                    # General utilities
│   └── widgets/                  # Shared/reusable widgets
│
├── features/                     # Feature modules
│   ├── dashboard/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── customers/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── data_sources/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── use_cases/
│   │   └── presentation/
│   │       ├── cubits/
│   │       ├── pages/
│   │       └── widgets/
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
├── l10n/                         # Localization files
│   ├── app_en.arb
│   ├── app_ar.arb
│   └── app_ur.arb
│
└── main.dart                     # App entry point
```

> **Note:** The above structure is the intended architecture. Actual implementation may vary. TODO: Verify this matches the current codebase and update if needed.

---

## 3. Core Layer

The **Core** layer contains shared infrastructure that is used across all features.

| Module | Purpose |
|---|---|
| `constants/` | App-wide constants (API keys, asset paths, enums) |
| `di/` | Dependency injection configuration (get_it / injectable) |
| `error/` | Failure classes, exception handling utilities |
| `extensions/` | Extension methods on Dart/Flutter types |
| `utils/` | Date formatters, validators, helpers |
| `widgets/` | Reusable UI components (buttons, dialogs, inputs) |

---

## 4. Data Layer

The **Data** layer handles data persistence, transformation, and retrieval.

### Components

| Component | Responsibility |
|---|---|
| **Models** | Data Transfer Objects (DTOs) with `toJson`/`fromJson` |
| **Data Sources** | Direct interaction with database (local) or API (remote) |
| **Repository Implementations** | Implement domain repository interfaces |

### Data Flow
```
Database ──► Data Source ──► Repository Impl ──► Use Case ──► Cubit ──► UI
```

---

## 5. Domain Layer

The **Domain** layer contains the business logic and is independent of any framework.

### Components

| Component | Responsibility |
|---|---|
| **Entities** | Core business objects (pure Dart classes) |
| **Repository Interfaces** | Abstract contracts for data operations |
| **Use Cases** | Single-responsibility business operations |

### Use Case Pattern
```dart
// TODO: Verify this matches actual implementation
class GetAllCustomers {
  final CustomerRepository repository;

  GetAllCustomers(this.repository);

  Future<Either<Failure, List<Customer>>> call() {
    return repository.getAllCustomers();
  }
}
```

---

## 6. Presentation Layer

The **Presentation** layer handles UI rendering and user interaction.

### Components

| Component | Responsibility |
|---|---|
| **Pages** | Full-screen views (routes) |
| **Widgets** | Feature-specific UI components |
| **Cubits** | State management (business logic for UI) |
| **States** | Immutable state classes for each Cubit |

---

## 7. Cubit / State Management

InvoiceFlow Pro uses **flutter_bloc (Cubit)** for state management.

### Why Cubit over Bloc?
- Simpler API (methods instead of events)
- Less boilerplate
- Sufficient for the app's complexity level
- Easier to test and debug

### State Pattern
```dart
// TODO: Verify this matches actual implementation
abstract class CustomerState {}
class CustomerInitial extends CustomerState {}
class CustomerLoading extends CustomerState {}
class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  CustomerLoaded(this.customers);
}
class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}
```

### Cubit Lifecycle
```
User Action ──► Cubit Method ──► Use Case ──► Repository ──► Emit New State ──► UI Rebuilds
```

---

## 8. Local Database

| Aspect | Detail |
|---|---|
| **Technology** | TODO: Confirm (Hive / SQLite via drift / sqflite) |
| **Schema** | TODO: Document table/box structure |
| **Migrations** | TODO: Define migration strategy |
| **Encryption** | TODO: Evaluate for sensitive data |

### Data Models
- TODO: List all persisted entities
- TODO: Document relationships between entities
- TODO: Define indexing strategy for query performance

---

## 9. Localization System

| Aspect | Detail |
|---|---|
| **Framework** | Flutter intl (ARB files) |
| **Config File** | `l10n.yaml` |
| **Supported Locales** | English (en), Arabic (ar), Urdu (ur) |
| **RTL Support** | Automatic via Flutter's `Directionality` |

### ARB File Structure
```
l10n/
├── app_en.arb    # English (source language)
├── app_ar.arb    # Arabic translation
└── app_ur.arb    # Urdu translation
```

### Localization Rules
1. All user-facing strings must be in ARB files (no hardcoded strings).
2. English is the source language; other languages are translations.
3. Pluralization and gender forms must use ICU message format.
4. Date/time and number formatting must respect locale.

---

## 10. PDF Generation System

| Aspect | Detail |
|---|---|
| **Package** | TODO: Confirm (e.g., `pdf: ^3.x.x`) |
| **Fonts** | TODO: List embedded font files |
| **Templates** | TODO: Number of templates available |
| **Output** | PDF file saved to device / shared via intent |

### PDF Architecture
```
Invoice Data ──► PDF Builder ──► PDF Document ──► Save/Share
```

### Key Considerations
- Embedded fonts required for Arabic/Urdu rendering
- Logo compression to keep file size manageable
- Pagination for invoices with many line items
- RTL layout support for Arabic/Urdu invoices

→ See [PDF Engine Audit](../testing/pdf_engine_audit.md) for testing details.

---

## 11. Dependency Injection

| Aspect | Detail |
|---|---|
| **Package** | TODO: Confirm (e.g., `get_it` + `injectable`) |
| **Registration** | TODO: Lazy singleton vs. factory vs. singleton |
| **Configuration** | TODO: Location of DI setup file |

### DI Registration Order
1. Core services (database, logger, etc.)
2. Data sources
3. Repositories
4. Use cases
5. Cubits

---

## 12. Error Handling Strategy

### Error Categories

| Category | Handling |
|---|---|
| **Database Errors** | Catch at Data Source, convert to `Failure` |
| **Validation Errors** | Catch at Cubit level, show field-level errors |
| **PDF Errors** | Catch at PDF builder, show user-friendly message |
| **File System Errors** | Catch at backup/restore, show recovery options |
| **Unexpected Errors** | Global error handler, log to Crashlytics |

### Error Flow
```
Exception ──► Data Source ──► Repository (convert to Failure) ──► Use Case ──► Cubit (emit Error State) ──► UI (show error)
```

### Failure Classes
```dart
// TODO: Verify this matches actual implementation
abstract class Failure {
  final String message;
  Failure(this.message);
}

class DatabaseFailure extends Failure { ... }
class ValidationFailure extends Failure { ... }
class PdfFailure extends Failure { ... }
class FileSystemFailure extends Failure { ... }
```

---

## Architecture Decision Records (ADRs)

| # | Decision | Rationale | Date |
|---|---|---|---|
| ADR-001 | Use Cubit over Bloc | Simpler API, less boilerplate, sufficient for app complexity | TODO |
| ADR-002 | Feature-based folder structure | Better scalability and isolation than layer-based | TODO |
| ADR-003 | Offline-first architecture | Core product philosophy, target market needs | TODO |
| ADR-004 | TODO | TODO | TODO |

---

> _This document should be updated whenever significant architectural decisions or changes are made._
