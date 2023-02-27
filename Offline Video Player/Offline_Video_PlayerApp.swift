//
//  Offline_Video_PlayerApp.swift
//  Offline Video Player
//
//  Created by Maneesh M on 27/02/23.
//

import SwiftUI

@main
struct Offline_Video_PlayerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
