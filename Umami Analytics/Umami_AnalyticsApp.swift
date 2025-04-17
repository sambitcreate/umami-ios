//
//  Umami_AnalyticsApp.swift
//  Umami Analytics
//
//  Created by Sambit Biswas on 4/17/25.
//

import SwiftUI

@main
struct Umami_AnalyticsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
