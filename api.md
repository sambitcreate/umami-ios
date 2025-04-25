# Umami iOS App API Documentation

This document provides detailed information about how the Umami iOS app interacts with Umami backend servers, focusing on API compatibility issues and solutions.

## Table of Contents

1. [API Overview](#api-overview)
2. [API Version Detection](#api-version-detection)
3. [Endpoint Formats](#endpoint-formats)
4. [API Models](#api-models)
5. [Error Handling](#error-handling)
6. [Compatibility Solutions](#compatibility-solutions)
7. [Debugging Guide](#debugging-guide)

## API Overview

The Umami iOS app is designed to connect to existing Umami backend servers, which may be running different versions of the Umami API (v1 or v2). The app implements a robust system to detect the API version and adapt to different endpoint formats to ensure compatibility across various Umami server versions.

### Key Components

- **APIClient**: Core class that handles all API requests, detects API versions, and manages endpoint compatibility
- **WebsiteService**: Service layer that uses APIClient to fetch website data and handle caching
- **Model Structures**: Flexible data models that can adapt to different API response formats

## API Version Detection

The app automatically detects the Umami server's API version upon login:

```swift
func detectAPIVersion() {
    print("🔍 Attempting to detect Umami API version...")

    // Make a request to a common endpoint that exists in both v1 and v2
    let request = createRequest(path: "/api/me", method: "GET")

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                // This endpoint exists in v2
                self.apiVersion = .v2
                print("✅ Detected Umami API v2")
                self.checkRealtimeEndpointFormat()
            } else if httpResponse.statusCode == 404 {
                // Try a v1 specific endpoint
                let v1Request = self.createRequest(path: "/api/account", method: "GET")
                
                URLSession.shared.dataTask(with: v1Request) { data, response, error in
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            self.apiVersion = .v1
                            print("✅ Detected Umami API v1")
                            self.checkRealtimeEndpointFormat()
                        } else {
                            print("❓ Unable to determine API version, defaulting to v2")
                            self.apiVersion = .v2
                            self.checkRealtimeEndpointFormat()
                        }
                    }
                }.resume()
            } else {
                print("❓ Unable to determine API version, defaulting to v2")
                self.apiVersion = .v2
                self.checkRealtimeEndpointFormat()
            }
        } else {
            print("❓ Unable to determine API version, defaulting to v2")
            self.apiVersion = .v2
            self.checkRealtimeEndpointFormat()
        }
    }.resume()
}
```

## Endpoint Formats

Different versions of Umami use different endpoint formats for the same functionality. The app handles these variations by trying alternative endpoints when the primary endpoint fails.

### Endpoint Format Variations

| Functionality | v1 Format | v2 Format | Alternative Formats |
|---------------|-----------|-----------|---------------------|
| Stats | `/api/website/{id}/stats` | `/api/websites/{id}/stats` | `/api/v1/websites/{id}/stats` |
| Metrics | `/api/website/{id}/metrics` | `/api/websites/{id}/metrics` | `/api/metrics/{id}` |
| Realtime | `/api/website/{id}/realtime` | `/api/websites/{id}/realtime` | `/api/realtime/{id}`, `/api/v1/websites/{id}/realtime`, `/api/v1/website/{id}/realtime` |
| Pageviews | `/api/website/{id}/pageviews` | `/api/websites/{id}/pageviews` | - |

### Endpoint Format Detection and Caching

The app caches successful endpoint formats to avoid repeated trial-and-error:

```swift
// Example for realtime endpoint format caching
.handleEvents(receiveOutput: { _ in
    // Store the successful format for future use
    if path.contains("/api/websites/") {
        UserDefaults.standard.set("plural_realtime", forKey: "umami_realtime_format")
        print("✅ Caching successful endpoint format: plural_realtime")
    } else if path.contains("/api/realtime/") {
        UserDefaults.standard.set("alt_realtime", forKey: "umami_realtime_format")
        print("✅ Caching successful endpoint format: alt_realtime")
    } else if path.contains("/api/v1/websites/") {
        UserDefaults.standard.set("v1_plural_realtime", forKey: "umami_realtime_format")
        print("✅ Caching successful endpoint format: v1_plural_realtime")
    } else if path.contains("/api/v1/website/") {
        UserDefaults.standard.set("v1_singular_realtime", forKey: "umami_realtime_format")
        print("✅ Caching successful endpoint format: v1_singular_realtime")
    }
})
```

## API Models

The app uses flexible model structures that can adapt to different API response formats:

### WebsiteMetrics

```swift
struct WebsiteMetrics: Codable {
    let pageviews: [PageviewMetric]
    let sessions: [SessionMetric]
    let events: [EventMetric]
    let countries: [CountryMetric]
    let browsers: [BrowserMetric]
    let os: [OSMetric]
    let devices: [DeviceMetric]
    let referrers: [ReferrerMetric]
    let pages: [PageMetric]
    
    // Custom decoder to handle different API formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all fields with fallbacks to empty arrays if not present
        pageviews = try container.decodeIfPresent([PageviewMetric].self, forKey: .pageviews) ?? []
        sessions = try container.decodeIfPresent([SessionMetric].self, forKey: .sessions) ?? []
        events = try container.decodeIfPresent([EventMetric].self, forKey: .events) ?? []
        countries = try container.decodeIfPresent([CountryMetric].self, forKey: .countries) ?? []
        browsers = try container.decodeIfPresent([BrowserMetric].self, forKey: .browsers) ?? []
        os = try container.decodeIfPresent([OSMetric].self, forKey: .os) ?? []
        devices = try container.decodeIfPresent([DeviceMetric].self, forKey: .devices) ?? []
        referrers = try container.decodeIfPresent([ReferrerMetric].self, forKey: .referrers) ?? []
        pages = try container.decodeIfPresent([PageMetric].self, forKey: .pages) ?? []
    }
}
```

### WebsiteStatsResponse and WebsiteMetricsResponse

These models include custom initializers for both decoding API responses and creating mock data:

```swift
struct WebsiteStatsResponse: Codable {
    let websiteId: String?
    let startDate: String
    let endDate: String
    let stats: WebsiteStatsModel
    
    // Custom initializer for creating mock data
    init(websiteId: String, startDate: String, endDate: String, stats: WebsiteStatsModel) {
        self.websiteId = websiteId
        self.startDate = startDate
        self.endDate = endDate
        self.stats = stats
    }
    
    // Custom decoder to handle different API formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode websiteId, but make it optional
        websiteId = try container.decodeIfPresent(String.self, forKey: .websiteId)
        
        // Decode dates
        startDate = try container.decode(String.self, forKey: .startDate)
        endDate = try container.decode(String.self, forKey: .endDate)
        
        // Decode stats
        stats = try container.decode(WebsiteStatsModel.self, forKey: .stats)
    }
}
```

### RealtimeData

The RealtimeData model is particularly flexible to handle different API formats:

```swift
struct RealtimeData: Codable, RealtimeDataProtocol {
    let websiteId: String?
    let timestamp: Int64
    var pageviews: [RealtimePageview]
    let sessions: Int
    var events: [RealtimeEvent]
    let countries: [String: Int]
    let urls: [String: Int]?
    let referrers: [String: Int]?
    let series: RealtimeSeries?
    let totals: RealtimeTotals?
    
    // Custom decoder to handle different API formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode websiteId, but make it optional
        websiteId = try container.decodeIfPresent(String.self, forKey: .websiteId)
        
        // Decode timestamp
        timestamp = try container.decode(Int64.self, forKey: .timestamp)
        
        // Try to decode sessions, default to totals.visitors if not present
        if container.contains(.sessions) {
            sessions = try container.decode(Int.self, forKey: .sessions)
        } else if let totals = try container.decodeIfPresent(RealtimeTotals.self, forKey: .totals) {
            sessions = totals.visitors
        } else {
            sessions = 0
        }
        
        // Try to decode countries
        if container.contains(.countries) {
            countries = try container.decode([String: Int].self, forKey: .countries)
        } else {
            countries = [:]
        }
        
        // Try to decode urls
        urls = try container.decodeIfPresent([String: Int].self, forKey: .urls)
        
        // Try to decode referrers
        referrers = try container.decodeIfPresent([String: Int].self, forKey: .referrers)
        
        // Try to decode series
        series = try container.decodeIfPresent(RealtimeSeries.self, forKey: .series)
        
        // Try to decode totals
        totals = try container.decodeIfPresent(RealtimeTotals.self, forKey: .totals)
        
        // Try to decode pageviews or convert from urls
        if container.contains(.pageviews) {
            pageviews = try container.decode([RealtimePageview].self, forKey: .pageviews)
        } else {
            // Convert urls to pageviews if available
            pageviews = []
            if let urlData = urls {
                for (url, _) in urlData {
                    pageviews.append(RealtimePageview(url: url, title: nil, timestamp: timestamp))
                }
            }
        }
        
        // Try to decode events
        if container.contains(.events) {
            events = try container.decode([RealtimeEvent].self, forKey: .events)
        } else {
            events = []
        }
    }
}
```

## Error Handling

The app implements comprehensive error handling for API requests:

### API Error Types

```swift
enum APIError: Error {
    case invalidURL
    case unauthorized
    case networkError(Error)
    case serverError(String)
    case decodingError
    case unknown
    case endpointNotFound(String)
    case apiVersionMismatch
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please check the URL and try again."
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Error processing server response."
        case .endpointNotFound(let path):
            return "Endpoint not found: \(path). This may be due to an API version mismatch between the app and server."
        case .apiVersionMismatch:
            return "API version mismatch. The app may need to be updated to work with your Umami server version."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
```

### Special Handling for 404 Errors

The app treats 404 errors as potential API compatibility issues:

```swift
if httpResponse.statusCode == 404 {
    // Special handling for 404 errors - might be API version incompatibility
    print("⚠️ 404 Not Found: This might indicate an API version incompatibility")

    // Try to detect if this is a v1 vs v2 API issue
    if request.url?.path.contains("/api/websites") == true {
        // Check if we need to try alternative endpoint formats
        if self.apiVersion == .unknown {
            print("🔄 API version unknown, will try alternative endpoints on next request")
            self.detectAPIVersion()
        }
        throw APIError.endpointNotFound(request.url?.path ?? "unknown")
    } else {
        throw APIError.serverError("Endpoint not found (404): \(request.url?.path ?? "unknown")")
    }
}
```

## Compatibility Solutions

The app implements several strategies to ensure compatibility with different Umami server versions:

### 1. API Version Detection

The app detects the API version upon login and adapts its requests accordingly.

### 2. Alternative Endpoint Formats

When a primary endpoint fails, the app tries alternative endpoint formats:

```swift
private func tryAlternativeEndpoint<T: Decodable>(originalPath: String) -> AnyPublisher<T, Error>? {
    // Based on the detected API version, try alternative endpoint formats

    // If we're dealing with website stats endpoints, they might have different formats in v1 vs v2
    if originalPath.contains("/api/websites") && originalPath.contains("/stats") {
        if apiVersion == .v1 {
            // Try v1 format
            if let websiteId = extractWebsiteId(from: originalPath) {
                let v1Path = "/api/website/\(websiteId)/stats"
                print("🔄 Trying alternative v1 endpoint: \(v1Path)")
                let request = createRequest(path: v1Path, method: "GET")
                return performRequest(request: request)
            }
        }
    }
    
    // Similar logic for metrics endpoints
    if originalPath.contains("/api/websites") && originalPath.contains("/metrics") {
        if let websiteId = extractWebsiteId(from: originalPath) {
            // Check if we've already determined the metrics endpoint format
            let metricsFormat = UserDefaults.standard.string(forKey: "umami_metrics_format")
            
            if metricsFormat == "alt_metrics" {
                // Use the alternative format: /api/metrics/{id}
                let altPath = "/api/metrics/\(websiteId)"
                print("🔄 Trying alternative metrics endpoint: \(altPath)")
                let request = createRequest(path: altPath, method: "GET")
                return performRequest(request: request)
            } else if metricsFormat == "singular_metrics" || apiVersion == .v1 {
                // Use the singular format: /api/website/{id}/metrics
                let singularPath = "/api/website/\(websiteId)/metrics"
                print("🔄 Trying singular metrics endpoint: \(singularPath)")
                let request = createRequest(path: singularPath, method: "GET")
                return performRequest(request: request)
            }
            // ... more formats
        }
    }
    
    // ... more endpoint types
    
    return nil
}
```

### 3. Endpoint Format Caching

The app caches successful endpoint formats to avoid repeated trial-and-error:

```swift
.handleEvents(receiveOutput: { _ in
    // Store the successful format for future use
    print("✅ Found working endpoint: singular_metrics")
    UserDefaults.standard.set("singular_metrics", forKey: "umami_metrics_format")
    UserDefaults.standard.set(0, forKey: "umami_metrics_failure_count")
})
```

### 4. Flexible Model Structures

The app uses custom decoders to handle different API response formats.

## Debugging Guide

If you're experiencing API compatibility issues, follow these steps:

### 1. Check the Console Logs

Look for logs with these prefixes:
- `🔍` - API version detection
- `🔄` - Trying alternative endpoints
- `✅` - Successful endpoint detection
- `⚠️` - Warnings and errors

### 2. Verify API Version Detection

Make sure the app correctly detects your Umami server's API version. Look for logs like:
- `✅ Detected Umami API v1`
- `✅ Detected Umami API v2`

### 3. Check Endpoint Format Detection

Look for logs indicating endpoint format detection:
- `✅ Found working endpoint: singular_metrics`
- `✅ Found working endpoint: alt_metrics`
- `✅ Caching successful endpoint format: alt_realtime`

### 4. Common Issues and Solutions

#### 404 Errors

If you see `⚠️ 404 Not Found: This might indicate an API version incompatibility`:
- The app will automatically try alternative endpoint formats
- Check if any of the alternative formats succeed

#### Decoding Errors

If you see `⚠️ Decoding error for metrics data`:
- The API response format might be different from what the app expects
- Check your Umami server version and compare with the app's expected formats

#### Persistent Failures

If you see `⚠️ Note: Multiple persistent failures with metrics data`:
- The app has tried all known endpoint formats without success
- Your Umami server might be using a custom or newer API format

### 5. Reset Cached Endpoint Formats

If you've updated your Umami server or are experiencing issues, try resetting the cached endpoint formats:
1. Go to iOS Settings
2. Find the Umami Analytics app
3. Tap "Reset Cached API Formats"

This will force the app to re-detect the correct endpoint formats.

### 6. Server Compatibility

The app is designed to work with:
- Umami v1.x
- Umami v2.x

If you're using a custom fork or a very recent version, some API endpoints might have changed.
