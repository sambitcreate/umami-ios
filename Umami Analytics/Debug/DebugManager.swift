//
//  DebugManager.swift
//  Umami Analytics
//
//  Created by Sambit Biswas on 4/17/25.
//

import Foundation
import Combine

class DebugManager {
    static let shared = DebugManager()
    
    @Published var isDebugMode = false
    
    // This will be reset when the app is closed
    private init() {}
    
    // MARK: - Debug Mode
    
    func enableDebugMode() {
        isDebugMode = true
    }
    
    func disableDebugMode() {
        isDebugMode = false
    }
    
    // MARK: - Mock Data
    
    func getMockWebsites() -> [WebsiteModel] {
        return [
            WebsiteModel(
                id: "mock-website-1",
                name: "Example Blog",
                domain: "blog.example.com",
                shareId: "share-123",
                userId: "user-123",
                teamId: "team-123",
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 30))
            ),
            WebsiteModel(
                id: "mock-website-2",
                name: "Company Website",
                domain: "example.com",
                shareId: "share-456",
                userId: "user-123",
                teamId: "team-123",
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 60))
            ),
            WebsiteModel(
                id: "mock-website-3",
                name: "E-commerce Store",
                domain: "store.example.com",
                shareId: "share-789",
                userId: "user-123",
                teamId: "team-123",
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 15))
            )
        ]
    }
    
    func getMockStats() -> WebsiteStatsModel {
        return WebsiteStatsModel(
            pageviews: Int.random(in: 5000...15000),
            uniques: Int.random(in: 2000...8000),
            bounces: Int.random(in: 500...2000),
            totalTime: Int.random(in: 50000...150000)
        )
    }
    
    func getMockMetrics() -> WebsiteMetrics {
        // Generate dates for the last 7 days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var pageviews: [PageviewMetric] = []
        var sessions: [SessionMetric] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let dateString = ISO8601DateFormatter().string(from: date)
            
            pageviews.append(PageviewMetric(
                date: dateString,
                value: Int.random(in: 500...2000)
            ))
            
            sessions.append(SessionMetric(
                date: dateString,
                value: Int.random(in: 200...1000)
            ))
        }
        
        return WebsiteMetrics(
            pageviews: pageviews,
            sessions: sessions,
            events: [
                EventMetric(name: "Click", value: Int.random(in: 500...2000)),
                EventMetric(name: "Download", value: Int.random(in: 100...500)),
                EventMetric(name: "Signup", value: Int.random(in: 50...200))
            ],
            countries: [
                CountryMetric(code: "US", name: "United States", value: Int.random(in: 1000...3000)),
                CountryMetric(code: "GB", name: "United Kingdom", value: Int.random(in: 500...1500)),
                CountryMetric(code: "CA", name: "Canada", value: Int.random(in: 300...1000)),
                CountryMetric(code: "DE", name: "Germany", value: Int.random(in: 200...800)),
                CountryMetric(code: "FR", name: "France", value: Int.random(in: 100...600))
            ],
            browsers: [
                BrowserMetric(name: "Chrome", value: Int.random(in: 1000...3000)),
                BrowserMetric(name: "Safari", value: Int.random(in: 800...2000)),
                BrowserMetric(name: "Firefox", value: Int.random(in: 300...1000)),
                BrowserMetric(name: "Edge", value: Int.random(in: 200...800))
            ],
            os: [
                OSMetric(name: "Windows", value: Int.random(in: 1000...2500)),
                OSMetric(name: "macOS", value: Int.random(in: 800...2000)),
                OSMetric(name: "iOS", value: Int.random(in: 500...1500)),
                OSMetric(name: "Android", value: Int.random(in: 400...1200)),
                OSMetric(name: "Linux", value: Int.random(in: 100...500))
            ],
            devices: [
                DeviceMetric(device: "Desktop", value: Int.random(in: 2000...4000)),
                DeviceMetric(device: "Mobile", value: Int.random(in: 1500...3000)),
                DeviceMetric(device: "Tablet", value: Int.random(in: 300...1000))
            ],
            referrers: [
                ReferrerMetric(referrer: "google.com", value: Int.random(in: 1000...2500)),
                ReferrerMetric(referrer: "facebook.com", value: Int.random(in: 500...1500)),
                ReferrerMetric(referrer: "twitter.com", value: Int.random(in: 300...1000)),
                ReferrerMetric(referrer: "linkedin.com", value: Int.random(in: 200...800)),
                ReferrerMetric(referrer: "instagram.com", value: Int.random(in: 100...500)),
                ReferrerMetric(referrer: "(direct)", value: Int.random(in: 800...2000))
            ],
            pages: [
                PageMetric(url: "/", title: "Home", value: Int.random(in: 1000...3000)),
                PageMetric(url: "/blog", title: "Blog", value: Int.random(in: 500...1500)),
                PageMetric(url: "/products", title: "Products", value: Int.random(in: 400...1200)),
                PageMetric(url: "/about", title: "About Us", value: Int.random(in: 300...900)),
                PageMetric(url: "/contact", title: "Contact", value: Int.random(in: 200...700))
            ]
        )
    }
    
    func getMockRealtimeData() -> RealtimeData {
        return RealtimeData(
            websiteId: "mock-website-1",
            timestamp: Int64(Date().timeIntervalSince1970),
            pageviews: [
                RealtimePageview(url: "/", title: "Home", timestamp: Int64(Date().timeIntervalSince1970 - 60)),
                RealtimePageview(url: "/blog", title: "Blog", timestamp: Int64(Date().timeIntervalSince1970 - 120)),
                RealtimePageview(url: "/products", title: "Products", timestamp: Int64(Date().timeIntervalSince1970 - 180))
            ],
            sessions: Int.random(in: 5...20),
            events: [
                RealtimeEvent(name: "Click", timestamp: Int64(Date().timeIntervalSince1970 - 90), data: ["button": "signup"]),
                RealtimeEvent(name: "Download", timestamp: Int64(Date().timeIntervalSince1970 - 150), data: ["file": "brochure.pdf"])
            ],
            countries: ["US": 3, "GB": 2, "CA": 1]
        )
    }
}
