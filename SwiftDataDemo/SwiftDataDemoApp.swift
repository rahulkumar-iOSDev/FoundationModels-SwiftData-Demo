//
//  SwiftDataDemoApp.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 23/09/26.
//

import SwiftUI
import SwiftData

@main
struct SwiftDataDemoApp: App {

    @AppStorage("appAppearanceIsDarkMode") private var isDarkMode = false

    let container: ModelContainer = {
        let schema = Schema([Expense.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    init() {
    
    }

    var body: some Scene {
        WindowGroup {
            ExpenseListView(isDarkMode: $isDarkMode)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(container)
    }

    // MARK: - Wipe helper

    private func wipeAllDataOnLaunch() {
        let context = container.mainContext
        do {
            try context.deleteAll(of: Expense.self)
            print("Wiped all Expense data on launch")
        } catch {
            print("Failed to wipe: \(error.localizedDescription)")
        }
    }
    
}

extension ModelContext {
    func deleteAll<T: PersistentModel>(of modelType: T.Type) throws {
        try delete(model: T.self)
        try save()
    }
}
