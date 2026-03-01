//
//  WebsiteViewModel+Realtime.swift
//  Umami Analytics
//
//  Extracted from WebsiteViewModel.swift
//

import Foundation

// MARK: - Realtime Tab & Polling

extension WebsiteViewModel {

    func loadRealtimeTab(websiteId: String, period: StatsPeriod) async {
        guard contextMatches(websiteId: websiteId, period: period) else { return }
        startRealtimeSnapshotPolling(websiteId: websiteId)
    }

    func loadRealtimeSnapshot(websiteId: String) async {
        let result = await captureResult {
            try await service.fetchRealtimeSnapshotAsync(websiteId: websiteId)
        }

        guard selectedWebsite?.id == websiteId else { return }

        switch result {
        case .success(let snapshot):
            realtimeSnapshot = snapshot
            activeUsersCount = snapshot.sessions
            hasActiveUsersData = true
        case .failure(let error):
            setTabError(.realtime, error: error)
        }
    }

    func startRealtimeSnapshotPolling(websiteId: String) {
        stopRealtimeSnapshotPolling()

        realtimeSnapshotTask = Task { @MainActor [weak self] in
            guard let self else { return }

            while !Task.isCancelled, selectedWebsite?.id == websiteId, selectedDetailTab == .realtime {
                await loadRealtimeSnapshot(websiteId: websiteId)
                guard !Task.isCancelled else { break }
                try? await Task.sleep(nanoseconds: sleepInterval(for: realtimePollInterval))
            }
        }
    }

    func stopRealtimeSnapshotPolling() {
        realtimeSnapshotTask?.cancel()
        realtimeSnapshotTask = nil
    }

    func startRealtimeUpdates(websiteId: String) {
        stopRealtimeUpdates()

        activeUsersTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let updates = service.startRealtimeUpdatesAsync(for: websiteId, interval: realtimePollInterval)

            for await visitorCount in updates {
                guard !Task.isCancelled,
                      selectedWebsite?.id == websiteId,
                      selectedDetailTab == .overview else {
                    break
                }

                activeUsers = ActiveUsersResponse(visitors: visitorCount)
                activeUsersCount = visitorCount
                hasActiveUsersData = true
            }
        }
    }

    func stopRealtimeUpdates() {
        activeUsersTask?.cancel()
        activeUsersTask = nil

        if let websiteId = selectedWebsite?.id {
            service.stopRealtimeUpdates(for: websiteId)
        }
    }

    func handleDetailDisappear() {
        stopRealtimeSnapshotPolling()
        stopRealtimeUpdates()
    }
}
