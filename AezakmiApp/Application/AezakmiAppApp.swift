//
//  AezakmiAppApp.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI
import CoreData

@main
struct AezakmiAppApp: App {
    
    @StateObject private var container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environment(\.managedObjectContext, container.coreDataStack.context)
        }
    }
}


