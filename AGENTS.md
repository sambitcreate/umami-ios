IMPORTANT: keep the 2 in sync with each other

# CLAUDE.md

This file provides guidance for AI assistants working on the Umami Analytics iOS codebase.

## Project Overview

Umami Analytics is a native iOS client for the [Umami](https://umami.is) web analytics platform. It supports both **self-hosted** Umami instances (username/password auth with Bearer tokens) and **Umami Cloud** (API key auth via `x-umami-api-key` header). The app now includes a tabbed per-website analytics experience with overview, audience dimensions, events, sessions (summary), and realtime data.

## Build & Run

- **IDE**: Xcode 26+ required (explicit Liquid Glass APIs require the iOS 26 SDK)
- **Language**: Swift 5.9+
- **iOS target**: iOS 16+ (required by Swift Charts framework)
- **Project file**: `Umami Analytics.xcodeproj` (no workspace)
- **Dependencies**: None. The project uses only Apple-native frameworks — no SPM packages, CocoaPods, or Carthage.
- **Scheme**: "Umami Analytics"
- **Clean build**: Run `clean_project.sh` to remove derived data (paths are hardcoded to the original developer's machine)

### Build from command line

```bash
xcodebuild clean build -project "Umami Analytics.xcodeproj" -scheme "Umami Analytics" -destination 'generic/platform=iOS'
```

### Tests

```bash
xcodebuild test -project "Umami Analytics.xcodeproj" -scheme "Umami Analytics" -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5'
```

The project now includes model decoding tests (Swift Testing) and smoke UI tests (XCTest), but API integration coverage remains lightweight.

## Architecture

**MVVM** with **Combine** reactive bindings. No async/await — all async work uses Combine publishers.

```
Umami_AnalyticsApp (entry point)
  └── AppState (ObservableObject, syncs with AuthManager)
        ├── LoginView ← AuthManager (singleton)
        └── ContentView (TabView)
              ├── DashboardView ← WebsiteViewModel
              ├── WebsitesView  ← WebsiteViewModel
              │     ├── WebsiteDetailView
              │     ├── WebsiteFormView (sheet)
              │     └── TrackingScriptView (sheet)
              └── SettingsView
```

### Layer responsibilities

| Layer | Key files | Role |
|-------|-----------|------|
| **Views** | `ContentView.swift`, `LoginView.swift`, `WebsiteDetailView.swift`, `WebsiteOverviewTabView.swift`, `WebsiteAudienceTabView.swift`, `WebsiteEventsTabView.swift`, `WebsiteSessionsTabView.swift`, `WebsiteRealtimeTabView.swift`, `WebsiteManagementViews.swift`, `AnalyticsChartView.swift` | SwiftUI declarative UI |
| **ViewModels** | `WebsiteViewModel.swift` | Orchestrates data flow, holds `@Published` state, formats display values |
| **Services** | `WebsiteService.swift` | Business logic layer, wraps APIClient calls, manages CoreData caching, realtime polling |
| **Networking** | `APIClient.swift` | URLSession-based HTTP client returning `AnyPublisher<T, Error>` |
| **Auth** | `AuthManager.swift` | Singleton managing login/logout, token storage, session restoration |
| **Models** | `AuthModels.swift`, `WebsiteModels.swift`, `AdvancedAnalyticsModels.swift` | Codable DTOs matching Umami API contracts, tolerant decoding, tab and analytics support types |
| **Persistence** | `Persistence.swift`, `Umami_Analytics.xcdatamodeld` | CoreData stack for offline caching |

## Directory Structure

```
umami-ios/
├── Umami Analytics/                  # Main app target
│   ├── Umami_AnalyticsApp.swift      # @main entry point, AppState
│   ├── ContentView.swift             # TabView + DashboardView, WebsitesView, SettingsView, helper views
│   ├── Auth/
│   │   └── AuthManager.swift         # Singleton auth orchestration, Keychain storage
│   ├── Models/
│   │   ├── AuthModels.swift          # User, AuthResponse, ServerType, AuthError
│   │   ├── WebsiteModels.swift       # WebsiteModel, stats/metrics response types, DateRange
│   │   └── AdvancedAnalyticsModels.swift  # Dynamic analytics response models and tab enums
│   ├── Networking/
│   │   └── APIClient.swift           # HTTP client, APIError, endpoint methods
│   ├── Services/
│   │   └── WebsiteService.swift      # Service layer, CoreData ops, StatsPeriod enum
│   ├── ViewModels/
│   │   └── WebsiteViewModel.swift    # Main view model, @Published state
│   ├── Views/
│   │   ├── LoginView.swift           # Auth UI (self-hosted + cloud)
│   │   ├── WebsiteDetailView.swift   # Tabbed per-website analytics container
│   │   ├── WebsiteOverviewTabView.swift   # Overview analytics tab
│   │   ├── WebsiteAudienceTabView.swift   # Audience dimensions tab
│   │   ├── WebsiteEventsTabView.swift     # Events tab
│   │   ├── WebsiteSessionsTabView.swift   # Sessions summary tab
│   │   ├── WebsiteRealtimeTabView.swift   # Realtime tab
│   │   ├── WebsiteManagementViews.swift  # WebsiteFormView, TrackingScriptView
│   │   └── Charts/
│   │       └── AnalyticsChartView.swift  # Swift Charts (AreaMark + LineMark)
│   ├── Persistence.swift             # PersistenceController (CoreData stack)
│   ├── Umami_Analytics.xcdatamodeld/ # CoreData schema
│   └── Assets.xcassets/              # Images, colors, app icon
├── Umami AnalyticsTests/             # Unit tests (Swift Testing)
├── Umami AnalyticsUITests/           # UI smoke tests (XCTest)
├── Umami Analytics.xcodeproj/        # Xcode project
├── umami-icons.icon/                 # App icon source
├── api.md                            # Comprehensive Umami API reference
├── Roadmap.md                        # 7-phase feature roadmap
├── PLAN.md                           # Frontend-backend communication patterns
└── clean_project.sh                  # Build cleanup script
```

## Key Patterns and Conventions

### Naming

- **PascalCase**: Types, Views, ViewModels, Models (e.g., `WebsiteDetailView`, `WebsiteViewModel`)
- **camelCase**: Properties, methods, local variables (e.g., `loadWebsites()`, `selectedPeriod`)
- **MARK comments**: Used to organize code sections (e.g., `// MARK: - Authentication`, `// MARK: - CoreData Operations`)
- File headers include file name, project name, and creator

### Singletons

Both `AuthManager` and `WebsiteService` use the singleton pattern:
```swift
class AuthManager {
    static let shared = AuthManager()
    private init() { ... }
}
```

### State management

- **App-wide**: `AppState` (ObservableObject) syncs with `AuthManager.$isAuthenticated` via Combine
- **Feature-level**: `WebsiteViewModel` with `@Published` properties
- **View-level**: `@State` for local UI state
- **Dependency injection**: `@EnvironmentObject` for `AppState`, `@Environment(\.managedObjectContext)` for CoreData
- **Persistence**: Keychain for tokens/API keys (via Security framework), UserDefaults for preferences (server URL, starred websites), CoreData for offline website/stats cache

### Combine usage

All async operations return `AnyPublisher<T, Error>`. The standard consumption pattern is:
```swift
somePublisher
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { [weak self] completion in
            if case .failure(let error) = completion { ... }
        },
        receiveValue: { [weak self] value in ... }
    )
    .store(in: &cancellables)
```

Always use `[weak self]` in sink closures to prevent retain cycles.

### API client

- `APIClient` normalizes paths for Cloud vs self-hosted (`/api/` becomes `/v1/` for Cloud)
- Auth is set via headers: `Authorization: Bearer <token>` (self-hosted) or `x-umami-api-key: <key>` (cloud)
- JSON decoder uses `.convertFromSnakeCase` key strategy
- All timestamps are millisecond epoch (`Int64`)

### Error handling

Two custom error enums with human-readable `.message` properties:
- `APIError`: network, decoding, server, unauthorized, invalidURL, unknown
- `AuthError`: invalidURL, invalidCredentials, missingAPIKey, network, server, decoding, unknown

### SwiftUI patterns

- `.onAppear` for initial data loading
- `.onChange(of:)` with two-parameter closure syntax (iOS 17+: `{ _, newValue in }`)
- `.overlay` for loading indicators
- `.alert(isPresented:)` with computed Binding for optional error messages
- `.refreshable` for pull-to-refresh
- `.sheet(item:)` and `.sheet(isPresented:)` for modal presentations
- `#Preview` macros for SwiftUI previews

### CoreData schema

Four entities in `Umami_Analytics.xcdatamodeld`:
- **Item**: Template entity (unused, from Xcode template)
- **UmamiServer**: `url` (required), `name`, relationships to websites
- **UmamiWebsite**: `id` (required), `name` (required), `domain`, `lastUpdated`, relationships to server and stats
- **UmamiWebsiteStats**: `pageviews`, `visitors`, `bounceRate`, `avgDuration`, `date`, `period`, relationship to website

Code generation is set to `class` (auto-generated NSManagedObject subclasses).

## API Endpoints Used

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Self-hosted login |
| POST | `/api/auth/verify` | Verify token |
| POST | `/api/auth/logout` | Self-hosted logout |
| GET | `/api/websites?page=N&pageSize=N` | List websites (paginated) |
| GET | `/api/websites/{id}` | Get website details |
| POST | `/api/websites` | Create website |
| POST | `/api/websites/{id}` | Update website |
| DELETE | `/api/websites/{id}` | Delete website |
| GET | `/api/websites/{id}/stats?startAt=&endAt=` | Get website stats |
| GET | `/api/websites/{id}/pageviews?startAt=&endAt=&unit=` | Get pageview time series |
| GET | `/api/websites/{id}/metrics?startAt=&endAt=&type=` | Get metrics (path, referrer, etc.) |
| GET | `/api/websites/{id}/active` | Get active visitor count |
| GET | `/api/realtime/{websiteId}` | Get realtime snapshot |
| GET | `/api/websites/{id}/events` | Get paged event list |
| GET | `/api/websites/{id}/events/series` | Get event time series |
| GET | `/api/websites/{id}/values` | Get filter values by type |
| GET | `/api/websites/{id}/event-data/events` | Get event-data event values |
| GET | `/api/websites/{id}/event-data/fields` | Get event-data field list |
| GET | `/api/websites/{id}/event-data/properties` | Get event-data property list |
| GET | `/api/websites/{id}/event-data/stats` | Get event-data stats map |
| GET | `/api/websites/{id}/event-data/values` | Get event-data values |
| GET | `/api/websites/{id}/session-data/properties` | Get session-data property list |
| GET | `/api/websites/{id}/session-data/values` | Get session-data values |
| GET | `/api/websites/{id}/sessions` | Get paged sessions list |
| GET | `/api/websites/{id}/sessions/stats` | Get session stats map |
| GET | `/api/websites/{id}/sessions/weekly` | Get weekly sessions series |
| GET | `/api/websites/{id}/sessions/{sessionId}` | Get session detail |
| GET | `/api/websites/{id}/sessions/{sessionId}/activity` | Get session activity |
| GET | `/api/websites/{id}/sessions/{sessionId}/properties` | Get session properties |

Cloud endpoints use `/v1/` prefix instead of `/api/`.

## Important Caveats

- **ContentView.swift is large** (~784 lines): It contains `DashboardView`, `WebsitesView`, `SettingsView`, `WebsiteRowView`, `WebsiteFaviconView`, `StatCard`, and `DashboardWebsiteCard` — all in one file. Be careful with targeted edits.
- **Debug logging**: `APIClient` prints request/response details to console (including headers and response bodies). These should be removed or guarded before release.
- **No linting/formatting**: No SwiftLint, SwiftFormat, or `.editorconfig` is configured. Follow the existing code style.
- **No CI/CD**: No GitHub Actions, Fastlane, or other automation is set up.
- **Tabbed detail architecture**: `WebsiteDetailView` is now a tab container; tab content lives in dedicated files under `Views/`.
- **Realtime polling**: Active users are polled every 5 seconds via `/active`; realtime tab polling fetches `/realtime/{websiteId}` every 5 seconds while active.
- **Advanced analytics cache**: New analytics datasets are cached in-memory in `WebsiteService` (TTL 60 seconds). CoreData schema remains unchanged.
- **`StatsPeriod` enum** is defined in `WebsiteService.swift`, not in the models directory.

## Common Tasks

### Adding a new API endpoint

1. Add the method to `APIClient.swift` following the existing pattern (create request, perform request, return publisher)
2. Add a corresponding method in `WebsiteService.swift` that guards on `AuthManager.shared.apiClient`
3. Add `@Published` properties to `WebsiteViewModel.swift` if needed
4. Add any new Codable models to `WebsiteModels.swift`

### Adding a new view

1. Create the SwiftUI view file in `Umami Analytics/Views/`
2. Wire it up via `NavigationLink` or `.sheet` in the parent view
3. Use `@ObservedObject var viewModel: WebsiteViewModel` or `@StateObject` depending on ownership

### Adding a new CoreData entity

1. Edit the data model in `Umami_Analytics.xcdatamodeld`
2. Add save/fetch methods in `WebsiteService.swift` following the existing patterns
3. CoreData classes are auto-generated — no manual NSManagedObject subclasses needed

## Existing Documentation

- **`api.md`**: Complete Umami API reference with request/response examples
- **`Roadmap.md`**: 7-phase feature roadmap (foundations, dashboard, realtime, deep analytics, management, personalization, data governance)
- **`PLAN.md`**: Frontend-backend communication patterns (web-oriented, not iOS-specific)
