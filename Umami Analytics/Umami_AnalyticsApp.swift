//
//  Umami_AnalyticsApp.swift
//  Umami Analytics
//
//  Created by Sambit Biswas on 4/17/25.
//

import SwiftUI
import Combine
import CoreData

@main
struct Umami_AnalyticsApp: App {
    let persistenceController = PersistenceController.shared

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if appState.isAuthenticated {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(appState)
            } else {
                LoginView(isAuthenticated: $appState.isAuthenticated)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(appState)
            }
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        AuthManager.shared.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                self?.isAuthenticated = isAuthenticated
            }
            .store(in: &cancellables)

        WebsiteService.shared.purgeExpiredCoreDataStats()

#if DEBUG
        configureUITestFixturesIfNeeded()
#endif
    }

#if DEBUG
    private func configureUITestFixturesIfNeeded() {
        guard ProcessInfo.processInfo.arguments.contains("-uiTestingAuthenticated") else {
            return
        }

        AuthManager.shared.configureUITestSession()
        seedUITestWebsite()
        isAuthenticated = AuthManager.shared.isAuthenticated
    }

    private func seedUITestWebsite() {
        let context = PersistenceController.shared.container.viewContext
        let serverURL = AuthManager.shared.serverURL ?? "https://ui-test.umami.local"

        context.performAndWait {
            let serverRequest: NSFetchRequest<UmamiServer> = UmamiServer.fetchRequest()
            serverRequest.predicate = NSPredicate(format: "url == %@", serverURL)

            let server = (try? context.fetch(serverRequest).first) ?? UmamiServer(context: context)
            server.url = serverURL
            server.name = "UI Test Umami"

            let websiteRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
            websiteRequest.predicate = NSPredicate(format: "id == %@ AND server == %@", "ui-test-site", server)

            let website = (try? context.fetch(websiteRequest).first) ?? UmamiWebsite(context: context)
            website.id = "ui-test-site"
            website.name = "UI Test Site"
            website.domain = "example.com"
            website.lastUpdated = Date()
            website.server = server

            try? context.save()
        }
    }
#endif
}
