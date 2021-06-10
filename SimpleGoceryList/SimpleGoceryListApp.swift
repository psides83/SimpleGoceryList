//
//  SimpleGoceryListApp.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/10/21.
//

import SwiftUI

@main
struct SimpleGoceryListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
