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
    
    func saveContext(_ context: NSManagedObjectContext? = nil) {
        let context = context ?? self.context
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения контекста: \(error)")
        }
    }
}

extension CoreDataStack {
    
    @discardableResult
    func saveScanSession(
        lanDevices: [LanDeviceModel],
        bluetoothDevices: [BluetoothDeviceModel]
    ) throws -> ScanSession {
        
        let session = ScanSession(context: context)
        session.id = UUID()
        session.timeStamp = Date()
        
        for lan in lanDevices {
            let device = LanDeviceEntity(context: context)
            device.name = lan.name
            device.ip = lan.ipAdress
            device.mac = lan.macAddress
            device.scanSession = session
        }
        
        for bt in bluetoothDevices {
            let device = BluetoothDeviceEntity(context: context)
            device.uuid = bt.uuid
            device.name = bt.name
            device.rssi = Int32(bt.rssi)
            device.status = bt.status.rawValue
            device.scanSession = session
        }
        
        try context.save()
        return session
    }
}
