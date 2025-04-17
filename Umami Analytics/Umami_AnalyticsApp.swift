//
//  Umami_AnalyticsApp.swift
//  Umami Analytics
//
//  Created by Sambit Biswas on 4/17/25.
//

import SwiftUI
import Combine

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

class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isDebugMode: Bool = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Check if user is already authenticated
        AuthManager.shared.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                self?.isAuthenticated = isAuthenticated
            }
            .store(in: &cancellables)

        // Observe debug mode changes
        DebugManager.shared.$isDebugMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDebugMode in
                self?.isDebugMode = isDebugMode
                // If debug mode is enabled, set authenticated to true
                if isDebugMode {
                    self?.isAuthenticated = true
                }
            }
            .store(in: &cancellables)

        // Verify token if we think we're authenticated
        if AuthManager.shared.isAuthenticated {
            AuthManager.shared.verifyAuthentication { _ in }
        }
    }

    func enableDebugMode() {
        DebugManager.shared.enableDebugMode()
    }

    func disableDebugMode() {
        DebugManager.shared.disableDebugMode()
        // If we're not actually authenticated, reset the state
        if !AuthManager.shared.isAuthenticated {
            isAuthenticated = false
        }
    }
}
