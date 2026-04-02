//
//  Persistence.swift
//  Umami Analytics
//
//  Created by Sambit Biswas on 4/17/25.
//

import CoreData
import os

struct PersistenceController {
    static let shared = PersistenceController()

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.umami.analytics", category: "Persistence")

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            logger.error("Preview context save failed: \(nsError.localizedDescription)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Umami_Analytics")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                Self.logger.error("Failed to load persistent store: \(error.localizedDescription), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
