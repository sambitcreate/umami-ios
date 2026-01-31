# Umami Analytics (iOS)

A modern, privacy-friendly iOS client for [Umami Analytics](https://umami.is/) - a simple, fast, and privacy-focused alternative to Google Analytics. Supports both Umami Cloud and self-hosted instances.

![iOS 17.0+](https://img.shields.io/badge/iOS-17.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Xcode](https://img.shields.io/badge/Xcode-16.0-blue)
![MIT License](https://img.shields.io/badge/License-MIT-green)

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [API Support](#api-support)
- [Architecture](#architecture)
- [Development](#development)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

---

## Features

### 🎯 Core Functionality
- **Dual Authentication Support**
  - Umami Cloud API key authentication
  - Self-hosted JWT token authentication (username/password)
- **Multi-Server Support** - Connect to multiple Umami instances
- **Real-time Analytics** - Live visitor tracking
- **Historical Data** - View statistics for customizable time ranges
- **Comprehensive Metrics**
  - Page views and sessions
  - Visitors by country, browser, OS, and device
  - Top referrers and pages
  - Event tracking

### 🛠️ Technical Features
- **API Version Detection** - Automatically detects and adapts to Umami v1, v2, and v3
- **Flexible Response Handling** - Gracefully handles different API response formats
- **Secure Storage** - Tokens and API keys stored in iOS Keychain
- **SwiftUI** - Native iOS 17+ interface
- **Combine Framework** - Reactive data flow
- **Core Data** - Local caching for improved performance
- **Comprehensive Error Handling** - Detailed logging and user-friendly error messages

### 🔒 Privacy & Security
- No third-party analytics SDKs
- Direct API communication with your Umami instance
- Secure credential storage using iOS Keychain
- HTTPS-only connections

---

## Screenshots

### Login Screen
Server type selection with conditional fields for Cloud (API key) and Self-hosted (URL, username, password).

### Dashboard
Comprehensive website analytics overview with key metrics at a glance.

### Real-time Visitors
Live tracking of current visitors and page views.

---

## Requirements

- iOS 17.0+ / iPadOS 17.0+
- Xcode 16.0+
- Swift 5.9+
- A Umami Cloud account or self-hosted Umami instance (v1, v2, or v3)

---

## Installation

### Clone the Repository

```bash
git clone https://github.com/yourusername/umami-ios.git
cd umami-ios
```

### Open in Xcode

1. Open `Umami Analytics.xcodeproj` in Xcode
2. Select your target device (iOS Simulator or physical device)
3. Build and run (⌘R)

---

## Configuration

No configuration files needed! The app handles everything through the UI.

### For Umami Cloud
1. Select "Umami Cloud" on the login screen
2. Enter your API key (generate from [cloud.umami.is](https://cloud.umami.is))
3. Tap "Sign In"

### For Self-hosted Umami
1. Select "Self-hosted" on the login screen
2. Enter your server URL (e.g., `https://umami.example.com`)
3. Enter your username and password
4. Tap "Sign In"

---

## Usage

### First Time Setup

1. Launch the app
2. Choose your server type (Cloud or Self-hosted)
3. Enter your credentials
4. Tap "Sign In"

### Viewing Analytics

1. **Website List** - View all your tracked websites
2. **Select a Website** - Tap to view detailed analytics
3. **Time Range Selector** - Choose from preset ranges (24h, 7d, 30d, 90d) or custom dates
4. **Metrics Dashboard**
   - **Overview**: Page views, unique visitors, bounce rate, avg. session duration
   - **Real-time**: Live visitors and page views
   - **Breakdowns**: Countries, browsers, OS, devices, referrers, top pages

---

## API Support

This client supports multiple Umami API versions:

| Version | Status | Notes |
|---------|--------|-------|
| **v1** | ✅ Supported | Legacy self-hosted instances |
| **v2** | ✅ Supported | Self-hosted instances |
| **v3** | ✅ Supported | Latest self-hosted (recommended) |
| **Cloud** | ✅ Supported | Hosted Umami Cloud service |

### Authentication Methods

#### Umami Cloud
```swift
// Uses API key authentication
Header: x-umami-api-key: <your-api-key>
Base URL: https://api.umami.is/v1
```

#### Self-hosted (v3)
```swift
// Uses JWT Bearer token authentication
Header: Authorization: Bearer <token>
Endpoints:
- POST /api/auth/login
- POST /api/auth/verify
- GET /api/me
```

### API Endpoints Used

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/login` | POST | Authenticate and get token |
| `/api/auth/verify` | POST | Verify token validity |
| `/api/auth/logout` | POST | Invalidate token |
| `/api/me` | GET | Get current user info |
| `/api/websites` | GET | List all websites |
| `/api/websites/{id}/stats` | GET | Website statistics |
| `/api/websites/{id}/metrics` | GET | Detailed metrics |
| `/api/websites/{id}/pageviews` | GET | Page view data |
| `/api/websites/{id}/realtime` | GET | Real-time visitors |

---

## Architecture

### Project Structure

```
Umami Analytics/
├── Umami Analytics/
│   ├── Auth/
│   │   ├── AuthManager.swift          # Authentication state management
│   │   └── AuthModels.swift           # User, auth response models
│   ├── Models/
│   │   ├── WebsiteModels.swift        # Website, metrics, stats models
│   │   └── AuthModels.swift
│   ├── Networking/
│   │   └── APIClient.swift            # HTTP client with version detection
│   ├── Services/
│   │   └── WebsiteService.swift       # Business logic layer
│   ├── ViewModels/
│   │   └── WebsiteViewModel.swift     # State management for views
│   ├── Views/
│   │   ├── LoginView.swift            # Authentication UI
│   │   ├── WebsiteDetailView.swift   # Per-website analytics
│   │   └── Charts/
│   │       └── AnalyticsChartView.swift
│   ├── Debug/
│   │   └── DebugManager.swift         # Debug mode and mock data
│   ├── Persistence.swift             # Core Data stack
│   └── Umami_AnalyticsApp.swift
└── Umami Analytics.xcodeproj
```

### Key Components

#### AuthManager
Singleton that manages authentication state:
- Login/logout operations
- Token storage (Keychain)
- Server type detection (Cloud vs Self-hosted)
- API version detection

#### APIClient
Robust HTTP client with:
- Automatic API version detection
- Path normalization for Cloud vs self-hosted
- Flexible response decoding
- Comprehensive error handling
- Retry logic for alternative endpoints

#### Data Flow
```
View → ViewModel → Service → APIClient → Umami API
                 ↓
              Core Data Cache
```

---

## Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/umami-ios.git

# Open in Xcode
open umami-ios/Umami\ Analytics.xcodeproj

# Select scheme and run
# Product → Scheme → Umami Analytics
# Product → Run (⌘R)
```

### Running Tests

```bash
# Run all tests
xcodebuild test -scheme "Umami Analytics" -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run specific test
xcodebuild test -scheme "Umami Analytics" -only-testing:UmamiAnalyticsTests/MyTestCase
```

### Code Style

This project follows:
- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- [SwiftUI Best Practices](https://developer.apple.com/documentation/swiftui)
- SwiftLint for static analysis (recommended)

### Adding New Features

1. **New API Endpoint:**
   - Add method to `APIClient.swift`
   - Create corresponding model in `Models/`
   - Add service layer in `Services/`
   - Update ViewModel and View

2. **New Chart Type:**
   - Add model in `WebsiteModels.swift`
   - Update `AnalyticsChartView.swift`
   - Add data fetching in `WebsiteService.swift`

---

## Troubleshooting

### Common Issues

#### "Error processing server response"
- **Cause**: API response format mismatch
- **Solution**: Check Xcode console for detailed error logs showing the actual response data

#### "Unauthorized access"
- **Cause**: Invalid or expired credentials
- **Solution**: Log out and log back in

#### "Endpoint not found"
- **Cause**: API version mismatch between app and server
- **Solution**: App will automatically try alternative endpoints

#### Real-time data not loading
- **Cause**: Server may not support real-time endpoint
- **Solution**: App will try alternative endpoint formats automatically

### Debug Mode

Enable debug mode to see detailed API logs:
1. Go to Settings
2. Enable "Debug Mode"
3. Check Xcode console for detailed logs

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

```bash
# 1. Fork and clone the repo
git clone https://github.com/yourusername/umami-ios.git
cd umami-ios

# 2. Create a new branch
git checkout -b feature/my-feature

# 3. Make your changes
# Edit files, add features, fix bugs

# 4. Test your changes
# Open in Xcode and run tests

# 5. Commit
git add .
git commit -m "Describe your changes"

# 6. Push and create PR
git push origin feature/my-feature
```

### Code Review Guidelines

- Follow existing code style and conventions
- Add unit tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Umami iOS Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Acknowledgments

- **Umami Analytics** - The open-source analytics platform that made this app possible
- **Apple** - For SwiftUI, Combine, and excellent developer tools
- **Open Source Community** - For various libraries and tools used in this project

### Dependencies

This project uses the following open-source components:
- **SwiftUI** - Apple's UI framework
- **Combine** - Apple's reactive programming framework
- **Core Data** - Apple's persistence layer

---

## What Changed Recently

### September 23, 2025
- Added server selection on the login screen (Umami Cloud vs Self-hosted)
- Implemented Umami Cloud authentication via API key with `x-umami-api-key` header
- Added path normalization for Cloud API (`/api/*` → `/v1/*`)
- Fixed URL building to prevent query string percent-encoding issues
- Implemented stale-while-revalidate caching for responsive UX
- Added Core Data persistence with lightweight migration

### Recent Improvements (January 2025)
- **Authentication Updates**: Updated token verification flow for Umami v3 (uses POST `/api/auth/verify` first)
- **API Version Detection**: Enhanced detection to properly identify Umami v3 self-hosted instances
- **Flexible Model Decoding**: Made models more resilient to API response variations
- **Enhanced Error Logging**: Improved debugging with detailed response data on decoding errors
- **Bug Fixes**: Fixed "error processing server response" issues with optional model fields

---

## Quick Test Steps

### Cloud
1. Select `Umami.is`
2. Paste API key from Umami Cloud → Settings → API Keys
3. Sign In
4. Confirm websites load

### Self-hosted
1. Select `Self Hosted`
2. Enter server URL (e.g., `https://analytics.example.com`)
3. Enter username and password
4. Sign In
5. Confirm websites load

---

## Notes & Caveats

- Cloud login uses API key (recommended by Umami) rather than username/password
- The login UI shows `https://cloud.umami.is` as the Cloud host label, but API requests target `https://api.umami.is/v1/...`
- Existing users with a stored self-hosted URL are auto-selected into Self Hosted mode
- Saved Cloud setups are auto-selected into Umami.is mode

---

## Contact & Support

- **Issues**: Report bugs and feature requests on [GitHub Issues](https://github.com/yourusername/umami-ios/issues)
- **Discussions**: Ask questions and share ideas on [GitHub Discussions](https://github.com/yourusername/umami-ios/discussions)

---

**Made with ❤️ for the open-source community**

*Note: This is an unofficial client and is not affiliated with or endorsed by the Umami Analytics project.*
