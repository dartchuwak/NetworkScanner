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
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "AezakmiApp")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func performBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
    
    func saveContext(context: NSManagedObjectContext? = nil) throws {
        let context = context ?? self.viewContext
        guard context.hasChanges else { return }
        try context.save()
    }
}

extension CoreDataStack {
    func deleteAllData() throws {
        let ctx = viewContext
        
        try ctx.performAndWait {
            let model = container.managedObjectModel
            let entityNames = model.entities.compactMap { $0.name }
            
            for name in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                deleteRequest.resultType = .resultTypeObjectIDs
                
                let result = try ctx.execute(deleteRequest) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    let changes: [AnyHashable: Any] = [
                        NSDeletedObjectsKey: objectIDs
                    ]
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: changes,
                        into: [ctx]
                    )
                }
            }
        }
    }
}
