//
//  ScanSessionRepositoryProtocol.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import Foundation
import CoreData

enum SessionsSortOption: String, CaseIterable, Identifiable {
    case dateDesc = "По дате (новые сверху)"
    case dateAsc  = "По дате (старые сверху)"
    
    var id: Self { self }
}

protocol ScanSessionRepositoryProtocol {
    func fetchSessions(sort: SessionsSortOption, searchText: String) throws -> [ScanSession]
    func fetchDevices(for session: ScanSession, lanSort: LanSortOption, searchText: String) throws -> (lan: [LanDeviceEntity], bt: [BluetoothDeviceEntity])
}

final class ScanSessionRepository: ScanSessionRepositoryProtocol {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    private var context: NSManagedObjectContext {
        coreDataStack.context
    }
    
    func fetchSessions(
        sort: SessionsSortOption,
        searchText: String
    ) throws -> [ScanSession] {
        let request: NSFetchRequest<ScanSession> = ScanSession.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        if !searchText.isEmpty {
            let pLan = NSPredicate(format: "ANY lanDevices.name CONTAINS[cd] %@ OR ANY lanDevices.ip CONTAINS[cd] %@", searchText, searchText)
            let pBt  = NSPredicate(format: "ANY bluetoothDevices.name CONTAINS[cd] %@ OR ANY bluetoothDevices.uuid CONTAINS[cd] %@", searchText, searchText)
            let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [pLan, pBt])
            predicates.append(orPredicate)
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        switch sort {
        case .dateDesc:
            request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        case .dateAsc:
            request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: true)]
        }
        
        return try context.fetch(request)
    }
    
    func fetchDevices(
        for session: ScanSession,
        lanSort: LanSortOption,
        searchText: String
    ) throws -> (lan: [LanDeviceEntity], bt: [BluetoothDeviceEntity]) {
        
        let lan = try fetchLanDevices(for: session, sort: lanSort, searchText: searchText)
        let bt  = try fetchBtDevices(for: session, searchText: searchText)
        return (lan, bt)
    }
    
    // MARK: - Private запросы
    
    private func fetchLanDevices(
        for session: ScanSession,
        sort: LanSortOption,
        searchText: String
    ) throws -> [LanDeviceEntity] {
        let request: NSFetchRequest<LanDeviceEntity> = LanDeviceEntity.fetchRequest()
        
        var predicates: [NSPredicate] = [
            NSPredicate(format: "scanSession == %@", session)
        ]
        
        if !searchText.isEmpty {
            predicates.append(
                NSPredicate(format: "(name CONTAINS[cd] %@) OR (ip CONTAINS[cd] %@)",
                            searchText, searchText)
            )
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        switch sort {
        case .name:
            request.sortDescriptors = [
                NSSortDescriptor(
                    key: "name",
                    ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )
            ]
        case .ip:
            request.sortDescriptors = [
                NSSortDescriptor(
                    key: "ip",
                    ascending: true,
                    selector: #selector(NSString.localizedStandardCompare(_:))
                )
            ]
        }
        
        return try context.fetch(request)
    }
    
    private func fetchBtDevices(
        for session: ScanSession,
        searchText: String
    ) throws -> [BluetoothDeviceEntity] {
        let request: NSFetchRequest<BluetoothDeviceEntity> = BluetoothDeviceEntity.fetchRequest()
        
        var predicates: [NSPredicate] = [
            NSPredicate(format: "scanSession == %@", session)
        ]
        
        if !searchText.isEmpty {
            predicates.append(
                NSPredicate(format: "name CONTAINS[cd] %@ OR uuid CONTAINS[cd] %@",
                            searchText, searchText)
            )
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        request.sortDescriptors = [
            NSSortDescriptor(
                key: "name",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )
        ]
        
        return try context.fetch(request)
    }
}
