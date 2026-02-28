//
//  AnalyticsRuntimeConfig.swift
//  Umami Analytics
//
//  Created by Codex on 2/7/26.
//

import Foundation

struct AnalyticsRuntimeConfig: Sendable {
    let dashboardRefreshInterval: TimeInterval
    let eventsSessionsPageSize: Int
    let analyticsCacheTTL: TimeInterval
    let realtimePollInterval: TimeInterval

    static let `default` = AnalyticsRuntimeConfig(
        dashboardRefreshInterval: 60,
        eventsSessionsPageSize: 20,
        analyticsCacheTTL: 60,
        realtimePollInterval: 5
    )
}
