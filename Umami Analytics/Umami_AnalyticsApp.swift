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
            AppRootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
        }
    }
}

private struct AppRootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            switch appState.phase {
            case .restoringSession:
                SessionRestoringView()
            case .signedIn:
                ContentView()
            case .signedOut:
                LoginView()
            }
        }
    }
}

private struct SessionRestoringView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Umami Analytics")
                .font(.title2.bold())

            ProgressView("Restoring your session")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .accessibilityElement(children: .combine)
    }
}

enum AppLaunchPhase: Equatable {
    case restoringSession
    case signedOut
    case signedIn
}

struct AppLaunchPhaseResolver {
    private(set) var hasResolvedInitialSession = false

    mutating func resolve(isAuthenticated: Bool, isLoading: Bool) -> AppLaunchPhase {
        if !hasResolvedInitialSession {
            guard !isLoading else {
                return .restoringSession
            }
            hasResolvedInitialSession = true
        }

        return isAuthenticated ? .signedIn : .signedOut
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var phase: AppLaunchPhase = .restoringSession
    private var phaseResolver = AppLaunchPhaseResolver()
    private var cancellables = Set<AnyCancellable>()

    init() {
#if DEBUG
        configureUITestFixturesIfNeeded()
#endif

        let authManager = AuthManager.shared
        Publishers.CombineLatest(authManager.$isAuthenticated, authManager.$isLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated, isLoading in
                self?.updateLaunchPhase(isAuthenticated: isAuthenticated, isLoading: isLoading)
            }
            .store(in: &cancellables)

        WebsiteService.shared.purgeExpiredCoreDataStats()
    }

    private func updateLaunchPhase(isAuthenticated: Bool, isLoading: Bool) {
        phase = phaseResolver.resolve(isAuthenticated: isAuthenticated, isLoading: isLoading)
    }

#if DEBUG
    private func configureUITestFixturesIfNeeded() {
        guard ProcessInfo.processInfo.arguments.contains("-uiTestingAuthenticated") else {
            return
        }

        AuthManager.shared.configureUITestSession()
        seedUITestWebsite()
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
