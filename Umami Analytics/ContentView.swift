//
//  ContentView.swift
//  Umami Analytics
//
//  Created by Sambit Biswas on 4/17/25.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0
    @StateObject private var websiteViewModel = WebsiteViewModel()
    @ObservedObject private var authManager = AuthManager.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(viewModel: websiteViewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
                .tag(0)

            WebsitesView(viewModel: websiteViewModel)
                .tabItem {
                    Label("Websites", systemImage: "globe")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .liquidGlassReadyTabChrome()
        .onChange(of: authManager.selectedWorkspace) { newSelection in
            websiteViewModel.applyWorkspaceSelection(newSelection)
        }
        .onChange(of: selectedTab) { _ in
            updateDashboardRefreshState()
        }
        .onChange(of: scenePhase) { _ in
            updateDashboardRefreshState()
        }
        .onAppear {
            updateDashboardRefreshState()
        }
    }

    private func updateDashboardRefreshState() {
        if selectedTab == 0 && scenePhase == .active {
            websiteViewModel.startBackgroundRefresh()
        } else {
            websiteViewModel.stopBackgroundRefresh()
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())
}

private extension View {
    @ViewBuilder
    func liquidGlassReadyTabChrome() -> some View {
        if #available(iOS 26.0, *) {
            self
                .tabViewStyle(.sidebarAdaptable)
                .tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }
}
