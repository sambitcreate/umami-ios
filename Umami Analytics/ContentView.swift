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

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
                .tag(0)

            WebsitesView()
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
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())
}
