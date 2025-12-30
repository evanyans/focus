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
            BlockingSchedule.self,
            UsageAttempt.self,
            OverrideSession.self,
            FocusSession.self,  // Keep for migration purposes
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
            MainAppView()
        }
        .modelContainer(sharedModelContainer)
    }
}
