# Umami Analytics for iOS

A native iOS client for [Umami](https://umami.is), the privacy-focused, open-source web analytics platform. View your website stats, track visitors in real time, and manage your sites -- all from your iPhone.

## Features

- **Dashboard** -- At-a-glance stats across all your websites with charts, visitor counts, and starred sites
- **Per-site analytics** -- Drill into any website with tabbed views:
  - **Overview** -- Pageviews, visitors, bounce rate, session duration over time
  - **Audience** -- Breakdowns by browser, OS, device, country, language, and more
  - **Events** -- Custom event tracking and event-data exploration
  - **Sessions** -- Session summaries and individual session activity
  - **Realtime** -- Live active visitors with 5-second polling
- **Website management** -- Create, edit, and delete websites; copy tracking scripts
- **Multi-workspace support** -- Switch between workspaces and teams
- **Dual auth** -- Works with both self-hosted Umami (username/password) and Umami Cloud (API key)
- **Offline caching** -- CoreData persistence so your data is available without a connection
- **Dark mode** -- Full support with light, dark, and tinted app icons

## Screenshots

*Coming soon*

## Requirements

- iOS 16.0+
- Xcode 16.3+
- Swift 5.9+
- A running [Umami](https://umami.is) instance (self-hosted or Cloud)

## Getting Started

1. **Clone the repo**
   ```bash
   git clone https://github.com/user/umami-ios.git
   cd umami-ios
   ```

2. **Open in Xcode**
   ```bash
   open "Umami Analytics.xcodeproj"
   ```

3. **Build and run** -- Select the "Umami Analytics" scheme, pick a simulator or device, and hit Run.

There are **no external dependencies** -- the project uses only Apple-native frameworks (SwiftUI, Combine, CoreData, Swift Charts, Security).

### Command-line build

```bash
xcodebuild clean build \
  -project "Umami Analytics.xcodeproj" \
  -scheme "Umami Analytics" \
  -destination 'generic/platform=iOS'
```

### Running tests

```bash
xcodebuild test \
  -project "Umami Analytics.xcodeproj" \
  -scheme "Umami Analytics" \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Connecting to Umami

When you launch the app, you'll see a login screen with two options:

| Mode | What you need |
|------|---------------|
| **Self-hosted** | Your Umami server URL, username, and password |
| **Umami Cloud** | An API key from [cloud.umami.is](https://cloud.umami.is) |

The app securely stores your credentials in the iOS Keychain.

## Architecture

The app follows **MVVM** with **Combine** for reactive data flow.

```
App Entry Point
  └── AppState (ObservableObject)
        ├── LoginView ← AuthManager
        └── Main TabView
              ├── Dashboard ← WebsiteViewModel
              ├── Websites  ← WebsiteViewModel
              │     └── Website Detail (tabbed analytics)
              └── Settings
```

| Layer | Purpose |
|-------|---------|
| **Views** | SwiftUI screens and components |
| **ViewModels** | `@Published` state, data orchestration |
| **Services** | Business logic, CoreData caching, polling |
| **Networking** | URLSession HTTP client returning Combine publishers |
| **Models** | Codable DTOs matching the Umami API |

## Project Structure

```
Umami Analytics/
├── Umami_AnalyticsApp.swift          # @main entry point
├── Auth/
│   └── AuthManager.swift             # Login, logout, token/key storage
├── Models/
│   ├── AuthModels.swift              # User, auth responses, server types
│   ├── WebsiteModels.swift           # Website, stats, metrics models
│   └── AdvancedAnalyticsModels.swift # Dynamic analytics & tab types
├── Networking/
│   └── APIClient.swift               # HTTP client with Cloud/self-hosted routing
├── Services/
│   └── WebsiteService.swift          # Data fetching, caching, polling
├── ViewModels/
│   ├── WebsiteViewModel.swift        # Main view model
│   └── WebsiteViewModel+*.swift      # Extensions per feature area
├── Views/
│   ├── DashboardView.swift           # Home dashboard
│   ├── WebsitesListView.swift        # Website list
│   ├── WebsiteDetailView.swift       # Tabbed per-site analytics
│   ├── Website*TabView.swift         # Individual analytics tabs
│   ├── SettingsView.swift            # App settings & account
│   ├── LoginView.swift               # Authentication screen
│   ├── Components/                   # Reusable UI (StatCard, favicon)
│   └── Charts/                       # Swift Charts views
└── Persistence.swift                 # CoreData stack
```

## Roadmap

The project has a [7-phase roadmap](Roadmap.md) covering:

1. Foundations & infrastructure
2. Dashboard & website management
3. Realtime analytics
4. Deep analytics & filtering
5. Advanced management
6. Personalization & UX polish
7. Data governance & compliance

## Contributing

Contributions are welcome! Please open an issue first to discuss what you'd like to change.

## License

This project is provided as-is. See the repository for license details.
