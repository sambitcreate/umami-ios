//
//  WebsiteViewModel+Dashboard.swift
//  Umami Analytics
//
//  Extracted from WebsiteViewModel.swift
//

import Foundation

// MARK: - Dashboard Stats & Starred Websites

extension WebsiteViewModel {

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
