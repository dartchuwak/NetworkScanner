//
//  Persistence.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    let container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "AezakmiApp")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveContext(_ context: NSManagedObjectContext? = nil) throws {
        let context = context ?? self.context
        guard context.hasChanges else { return }
            try context.save()
    }
}
