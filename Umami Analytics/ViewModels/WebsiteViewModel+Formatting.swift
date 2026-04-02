//
//  WebsiteViewModel+Formatting.swift
//  Umami Analytics
//
//  Extracted from WebsiteViewModel.swift
//

import Foundation

// MARK: - Display Formatting & Helpers

extension WebsiteViewModel {

    var hasWebsites: Bool {
        !filteredWebsites.isEmpty
    }

    var formattedPageviews: String {
        guard let stats = websiteStats else { return "--" }
        return formatNumber(stats.pageviews)
    }

    var formattedVisitors: String {
        guard let stats = websiteStats else { return "--" }
        return formatNumber(stats.visitors)
    }

    var formattedBounceRate: String {
        guard let stats = websiteStats else { return "--" }
        return String(format: "%.1f%%", stats.bounceRate * 100)
    }

    var formattedDuration: String {
        guard let stats = websiteStats else { return "--" }
        let seconds = stats.avgDuration

        if seconds < 60 {
            return String(format: "%.0fs", seconds)
        }

        let minutes = Int(seconds / 60)
        let remainingSeconds = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%dm %ds", minutes, remainingSeconds)
    }

    func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if number >= 1_000_000 {
            formatter.maximumFractionDigits = 1
            return (formatter.string(from: NSNumber(value: Double(number) / 1_000_000)) ?? "0") + "M"
        }

        if number >= 1_000 {
            formatter.maximumFractionDigits = 1
            return (formatter.string(from: NSNumber(value: Double(number) / 1_000)) ?? "0") + "K"
        }

        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }

    func setRootError(_ error: Error) {
        if let apiError = error as? APIError {
            errorMessage = apiError.message
        } else {
            errorMessage = error.localizedDescription
        }
    }

    func setTabError(_ tab: WebsiteDetailTab, error: Error) {
        if let apiError = error as? APIError {
            tabErrors[tab] = apiError.message
        } else {
            tabErrors[tab] = error.localizedDescription
        }
    }

    func setTabLoading(_ tab: WebsiteDetailTab, _ loading: Bool) {
        tabLoading[tab] = loading
    }
}
