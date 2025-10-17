//
//  WebsiteViewModel.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import Combine
import SwiftUI

class WebsiteViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    // Published properties for UI updates
    @Published var websites: [WebsiteModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedPeriod: StatsPeriod = .day

    // Selected website properties
    @Published var selectedWebsite: WebsiteModel?
    @Published var websiteStats: WebsiteStatsResponse?
    @Published var websiteMetrics: WebsiteMetricsResponse?
    @Published var pageviewsData: PageviewsResponse?
    @Published var activeUsers: ActiveUsersResponse?
    @Published var activeUsersCount: Int = 0
    @Published var hasActiveUsersData: Bool = false

    // Computed properties for UI
    var hasWebsites: Bool {
        !websites.isEmpty
    }

    var formattedPageviews: String {
        guard let stats = websiteStats else { return "--" }
        return formatNumber(stats.pageviews.value)
    }

    var formattedVisitors: String {
        guard let stats = websiteStats else { return "--" }
        return formatNumber(stats.visitors.value)
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
        } else {
            let minutes = Int(seconds / 60)
            let remainingSeconds = Int(seconds.truncatingRemainder(dividingBy: 60))
            return String(format: "%dm %ds", minutes, remainingSeconds)
        }
    }

    // MARK: - Initialization

    init() {
        // Load cached websites on init
        loadCachedWebsites()
    }

    // MARK: - Data Loading

    func loadWebsites() {
        isLoading = true
        errorMessage = nil

        WebsiteService.shared.fetchWebsites()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false

                    if case .failure(let error) = completion {
                        if let apiError = error as? APIError {
                            self?.errorMessage = apiError.message
                        } else {
                            self?.errorMessage = error.localizedDescription
                        }

                        // Load from cache if network request fails
                        self?.loadCachedWebsites()
                    }
                },
                receiveValue: { [weak self] websites in
                    self?.websites = websites

                    // If we have a selected website, refresh its data
                    if let selectedId = self?.selectedWebsite?.id,
                       let website = websites.first(where: { $0.id == selectedId }) {
                        self?.selectedWebsite = website
                        self?.loadWebsiteData(website: website)
                    }
                    // Otherwise select the first website if available
                    else if let firstWebsite = websites.first, self?.selectedWebsite == nil {
                        self?.selectWebsite(firstWebsite)
                    }
                }
            )
            .store(in: &cancellables)
    }

    func loadCachedWebsites() {
        let cachedWebsites = WebsiteService.shared.fetchCachedWebsites()

        if !cachedWebsites.isEmpty {
            // Convert CoreData objects to model objects
            let modelWebsites = cachedWebsites.map { cdWebsite -> WebsiteModel in
                return WebsiteModel(
                    id: cdWebsite.id ?? "",
                    name: cdWebsite.name ?? "Unknown",
                    domain: cdWebsite.domain ?? "",
                    shareId: nil,
                    userId: nil,
                    teamId: nil,
                    createdAt: ISO8601DateFormatter().string(from: cdWebsite.lastUpdated ?? Date())
                )
            }

            DispatchQueue.main.async {
                self.websites = modelWebsites

                // Select first website if none is selected
                if self.selectedWebsite == nil, let firstWebsite = modelWebsites.first {
                    self.selectWebsite(firstWebsite)
                }
            }
        }
    }

    func selectWebsite(_ website: WebsiteModel) {
        selectedWebsite = website
        loadWebsiteData(website: website)
    }

    func loadWebsiteData(website: WebsiteModel) {
        hasActiveUsersData = false
        activeUsersCount = 0

        loadWebsiteStats(websiteId: website.id)
        loadWebsiteMetrics(websiteId: website.id)
        loadPageviewsData(websiteId: website.id)
        loadActiveUsers(websiteId: website.id)
        startRealtimeUpdates(websiteId: website.id)
    }

    func changePeriod(_ period: StatsPeriod) {
        selectedPeriod = period

        if let website = selectedWebsite {
            loadWebsiteStats(websiteId: website.id)
            loadWebsiteMetrics(websiteId: website.id)
            loadPageviewsData(websiteId: website.id)
            loadActiveUsers(websiteId: website.id)
        }
    }

    // MARK: - Stats and Metrics

    private func loadWebsiteStats(websiteId: String) {
        isLoading = true

        WebsiteService.shared.fetchWebsiteStats(id: websiteId, period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false

                    if case .failure(let error) = completion {
                        if let apiError = error as? APIError {
                            self?.errorMessage = apiError.message
                        } else {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    self?.websiteStats = response
                }
            )
            .store(in: &cancellables)
    }

    private func loadWebsiteMetrics(websiteId: String) {
        WebsiteService.shared.fetchWebsiteMetrics(id: websiteId, period: selectedPeriod, type: "url")
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        if let apiError = error as? APIError {
                            self?.errorMessage = apiError.message
                        } else {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    self?.websiteMetrics = response
                }
            )
            .store(in: &cancellables)
    }

    private func loadPageviewsData(websiteId: String) {
        WebsiteService.shared.fetchWebsitePageviews(id: websiteId, period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    _ = self // Suppress unused variable warning
                    if case .failure(let error) = completion {
                        print("Failed to load pageviews: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.pageviewsData = response
                }
            )
            .store(in: &cancellables)
    }

    private func loadActiveUsers(websiteId: String) {
        WebsiteService.shared.fetchActiveUsers(id: websiteId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    _ = self // Suppress unused variable warning
                    if case .failure(let error) = completion {
                        print("Failed to load active users: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.activeUsers = response
                    self?.activeUsersCount = response.visitors
                    self?.hasActiveUsersData = true
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Realtime Updates

    private func startRealtimeUpdates(websiteId: String) {
        WebsiteService.shared.startRealtimeUpdates(for: websiteId) { [weak self] count in
            DispatchQueue.main.async {
                self?.activeUsersCount = count
                self?.hasActiveUsersData = true
            }
        }
    }

    func stopRealtimeUpdates() {
        if let websiteId = selectedWebsite?.id {
            WebsiteService.shared.stopRealtimeUpdates(for: websiteId)
        }
    }

    // MARK: - Helper Methods

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if number >= 1_000_000 {
            formatter.maximumFractionDigits = 1
            return formatter.string(from: NSNumber(value: Double(number) / 1_000_000)) ?? "0" + "M"
        } else if number >= 1_000 {
            formatter.maximumFractionDigits = 1
            return formatter.string(from: NSNumber(value: Double(number) / 1_000)) ?? "0" + "K"
        } else {
            return formatter.string(from: NSNumber(value: number)) ?? "0"
        }
    }

    // MARK: - Cleanup

    deinit {
        stopRealtimeUpdates()
    }
}
