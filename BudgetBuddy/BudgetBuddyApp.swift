//
//  BudgetBuddyApp.swift
//  BudgetBuddy
//
//  Created by Yade KANBİR on 2.05.2023.
//

import SwiftUI

@main
struct BudgetBuddyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
