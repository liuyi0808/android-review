# Modularization Strategy

## Module Types

```
:app                    → Application module (wiring, navigation)
:feature:login          → Feature module (UI + ViewModel)
:feature:home           → Feature module
:core:data              → Data layer (repositories, data sources)
:core:domain            → Domain layer (models, use cases, interfaces)
:core:network           → Network (Retrofit, OkHttp)
:core:database          → Database (Room)
:core:ui                → Shared UI components, theme
:core:common            → Shared utilities, extensions
```

## Dependency Graph

```
:app → :feature:* → :core:domain
                  → :core:ui
:core:data → :core:domain
           → :core:network
           → :core:database
```

## Rules

1. Feature modules NEVER depend on other feature modules.
2. Feature modules depend on `:core:domain` and `:core:ui` only.
3. `:core:domain` has ZERO Android dependencies.
4. `:app` module is thin — only navigation and DI wiring.

## When to Modularize

- When build times exceed 2 minutes
- When team size exceeds 3 developers
- When features can be developed independently
- For small projects: single module is fine. Don't modularize prematurely.

## Checklist

- [ ] No circular dependencies between modules
- [ ] Feature modules don't depend on each other
- [ ] Domain module has no Android dependencies
- [ ] Build times acceptable (<2 min for incremental)
- [ ] API boundaries defined between modules
