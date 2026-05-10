//
//  ContentView.swift
//  Umami Analytics
//
//  Created by Sambit Biswas on 4/17/25.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var websiteViewModel = WebsiteViewModel()
    @ObservedObject private var authManager = AuthManager.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(viewModel: websiteViewModel)
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
        .onChange(of: authManager.selectedWorkspace) { _, newSelection in
            websiteViewModel.applyWorkspaceSelection(newSelection)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())
}
