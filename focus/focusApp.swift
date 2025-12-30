//
//  focusApp.swift
//  focus
//
//  Created by Evan Yan on 2025-12-13.
//

import SwiftUI
import SwiftData

@main
struct focusApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FocusSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            FocusSessionView()
        }
        .modelContainer(sharedModelContainer)
    }
}
