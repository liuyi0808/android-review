---
name: architecture
description: >-
  Android application architecture standards using Clean Architecture, MVVM/MVI
  patterns, Hilt dependency injection, and modularization. Use when: designing
  app structure, creating ViewModel/Repository/UseCase classes, setting up Hilt
  DI modules, planning module boundaries, reviewing layer dependencies, implementing
  offline-first data patterns, defining error handling strategy, or starting a new
  Android feature module.
---

# Android Architecture Standards

Enforce Clean Architecture patterns with MVVM/MVI for Android Kotlin applications.

## Architecture Review Process

Evaluate code against ALL layers. Output findings as:

```
[ARCH-XXXXX] severity: CRITICAL | HIGH | MEDIUM | LOW
  Finding: <architecture violation or improvement>
  Location: <file:line>
  Fix: <concrete refactoring guidance>
```

---

## 1. Layer Architecture

### Three Layers (Mandatory)

```
┌─────────────────────────────────┐
│        Presentation Layer       │  UI, ViewModel, UiState
│         (app / feature)         │
├─────────────────────────────────┤
│          Domain Layer           │  UseCase, Domain Model, Repository Interface
│           (optional)            │
├─────────────────────────────────┤
│           Data Layer            │  Repository Impl, DataSource, DTO, API, DB
│       (data / network)          │
└─────────────────────────────────┘
```

### Dependency Rule

Dependencies flow INWARD only:
- Presentation → Domain → Data (allowed)
- Data → Domain (NEVER)
- Presentation → Data directly (AVOID, use Domain)

### Package Structure

```
com.example.app/
├── di/                          # Hilt modules
│   ├── AppModule.kt
│   ├── NetworkModule.kt
│   └── DatabaseModule.kt
├── data/
│   ├── local/
│   │   ├── dao/                 # Room DAOs
│   │   ├── entity/              # Room entities
│   │   └── AppDatabase.kt
│   ├── remote/
│   │   ├── api/                 # Retrofit interfaces
│   │   ├── dto/                 # Data Transfer Objects
│   │   └── interceptor/
│   ├── mapper/                  # DTO ↔ Domain mappers
│   └── repository/              # Repository implementations
├── domain/
│   ├── model/                   # Domain models (pure Kotlin)
│   ├── repository/              # Repository interfaces
│   └── usecase/                 # Use cases
└── ui/                          # Presentation
    ├── navigation/
    ├── theme/
    ├── component/               # Reusable composables
    └── screen/
        ├── login/
        │   ├── LoginScreen.kt
        │   ├── LoginViewModel.kt
        │   └── LoginUiState.kt
        └── home/
            ├── HomeScreen.kt
            ├── HomeViewModel.kt
            └── HomeUiState.kt
```

---

## Reference Guide — Load on Demand

Each reference file contains full code examples, patterns, and detailed checklists. **Read the relevant file when reviewing that layer.**

| # | Reference File | Content | When to Load |
|---|---------------|---------|-------------|
| 1 | [references/presentation.md](references/presentation.md) | ViewModel, UiState, Actions, Events, Screen Composable | Reviewing presentation layer or ViewModel patterns |
| 2 | [references/domain.md](references/domain.md) | UseCase pattern, Domain Model, Repository Interface | Reviewing domain layer or use case design |
| 3 | [references/data.md](references/data.md) | Repository Impl, Mapper, Offline-First pattern | Reviewing data layer or repository implementation |
| 4 | [references/di.md](references/di.md) | Hilt Module Structure, scope rules | Setting up or reviewing dependency injection |
| 5 | [references/modularization.md](references/modularization.md) | Module types, dependency graph, when to modularize | Planning module boundaries |
| 6 | [references/error-handling.md](references/error-handling.md) | Error pattern, exception hierarchy | Designing error handling strategy |

---

## Rules Summary

### Presentation Layer
1. ViewModel NEVER references `Context`, `Activity`, or `View`.
2. ViewModel exposes `StateFlow` (NOT `LiveData` for new code).
3. UI state is a single immutable data class per screen.
4. Actions from UI → ViewModel via sealed interface.
5. One-time events via `Channel.receiveAsFlow()`.
6. Screen composable splits into: wired (with ViewModel) + stateless content.

### Domain Layer
1. Domain layer has ZERO Android dependencies (pure Kotlin).
2. UseCase has single `invoke` operator (one operation per UseCase).
3. Repository interfaces defined in domain, implemented in data.
4. Domain models are independent of DTO/Entity (separate mapping).
5. Use `Result<T>` for operations that can fail.

### Data Layer
1. Repository is the single source of truth.
2. DTO (API response) ≠ Entity (Room) ≠ Domain Model. Map between them.
3. Offline-first: Room as source of truth, network refreshes in background.
4. API calls wrapped in `runCatching` — NEVER throw unhandled exceptions.
5. DataSource abstraction: `LocalDataSource` + `RemoteDataSource` → `Repository`.

### Dependency Injection (Hilt)
1. Use `@Binds` for interface→implementation bindings (more efficient than `@Provides`).
2. Use correct `@InstallIn` scope (`SingletonComponent`, `ViewModelComponent`, `ActivityComponent`).
3. NEVER inject `Activity` or `Fragment` into non-UI classes.
4. Use `@ApplicationContext` when Context is needed in singletons.

### Modularization
1. Feature modules NEVER depend on other feature modules.
2. Feature modules depend on `:core:domain` and `:core:ui` only.
3. `:core:domain` has ZERO Android dependencies.
4. `:app` module is thin — only navigation and DI wiring.

### Error Handling
1. Use `Result<T>` for all fallible operations in domain/data layers.
2. Map network exceptions to domain exceptions in Repository.
3. Present user-friendly messages in ViewModel (NEVER raw exception messages).
4. NEVER silently swallow exceptions — always log or report.
5. Use sealed class hierarchy for typed error handling.

---

## Checklists

### Presentation
- [ ] One ViewModel per screen
- [ ] UiState is immutable data class
- [ ] Actions modeled as sealed interface
- [ ] Events via Channel (not StateFlow)
- [ ] collectAsStateWithLifecycle used
- [ ] No Android framework imports in ViewModel (except SavedStateHandle)
- [ ] Screen split: wired container + stateless content

### Domain
- [ ] Domain models have no framework annotations
- [ ] UseCase is single-purpose with invoke operator
- [ ] Repository interface in domain package
- [ ] No Android imports in domain layer
- [ ] Result type for fallible operations

### Data
- [ ] DTO, Entity, Domain Model are separate classes
- [ ] Mappers exist between all data types
- [ ] Repository wraps API calls in runCatching
- [ ] Room as single source of truth (offline-first)
- [ ] No API/Room types leak to domain/presentation

### Dependency Injection
- [ ] @HiltAndroidApp on Application class
- [ ] @AndroidEntryPoint on Activities/Fragments
- [ ] @HiltViewModel on ViewModels
- [ ] Interfaces bound with @Binds (not @Provides)
- [ ] Correct scope for each dependency
- [ ] No manual dependency creation outside DI

### Modularization
- [ ] No circular dependencies between modules
- [ ] Feature modules don't depend on each other
- [ ] Domain module has no Android dependencies
- [ ] Build times acceptable (<2 min for incremental)
- [ ] API boundaries defined between modules

### Error Handling
- [ ] Result type used for fallible operations
- [ ] Exceptions mapped to domain types in Repository
- [ ] User-friendly error messages in ViewModel
- [ ] No raw exception messages shown to user
- [ ] Global error handler for uncaught exceptions

---

*For Compose UI patterns, see the `compose-ui` skill. For OWASP security audit, see the `security-audit` skill.*
