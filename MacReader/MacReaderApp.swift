//
//  MacReaderApp.swift
//  MacReader
//
//  Created by Anastasia Ivanova on 05.01.25.
//

import SwiftUI

@main
struct MacReaderApp: App {
    let persistentController = PersistentController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentController.context)
            //  By injecting the context here, it becomes available to all child views in the app.
        }
    }
}
