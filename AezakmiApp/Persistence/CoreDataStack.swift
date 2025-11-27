//
//  Persistence.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    private(set) var container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "AezakmiApp")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveDevice(device: BluetoothDeviceModel) {
        let entity = BluetoothDeviceEntity(context: context)
        entity.uuid = device.id
        entity.name = device.name
        entity.rssi = Int32(device.rssi)
        entity.status = device.status.rawValue
    }
    
    func save() {
        
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
