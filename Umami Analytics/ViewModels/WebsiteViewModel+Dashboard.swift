//
//  WebsiteViewModel+Dashboard.swift
//  Umami Analytics
//
//  Extracted from WebsiteViewModel.swift
//

import Foundation

// MARK: - Dashboard Stats & Starred Websites

extension WebsiteViewModel {

    var dashboardWebsites: [WebsiteModel] {
        let starred = websites.filter { starredWebsiteIds.contains($0.id) }
        if !starred.isEmpty {
            return Array(starred.prefix(3))
        }
        return Array(websites.prefix(3))
    }

    var hasStarredWebsites: Bool {
        !starredWebsiteIds.isEmpty && websites.contains(where: { starredWebsiteIds.contains($0.id) })
    }

    func isStarred(_ websiteId: String) -> Bool {
        starredWebsiteIds.contains(websiteId)
    }

    func toggleStar(_ websiteId: String) {
        if starredWebsiteIds.contains(websiteId) {
            starredWebsiteIds.remove(websiteId)
        } else {
            starredWebsiteIds.insert(websiteId)
        }
        saveStarredIds()
    }
}
