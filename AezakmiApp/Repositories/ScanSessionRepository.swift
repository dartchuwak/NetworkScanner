//
//  ScanSessionRepositoryProtocol.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import Foundation
import CoreData
import Combine

protocol ScanSessionRepositoryProtocol {
    // var errorStream: PassthroughSubject<Error, Never> { get }
    
    func saveSession(lanDevices: [LanDeviceModel], btDevices: [BluetoothDeviceModel]) throws
    func fetchSessions(sort: SessionsSortOption,searchText: String) throws -> [ScanSession]
    func fetchDevices(session: ScanSession, lanSort: LanSortOption, searchText: String) -> AnyPublisher<([BluetoothDeviceModel],[LanDeviceModel]), Error>
}

final class ScanSessionRepository: ScanSessionRepositoryProtocol {
    
    private let coreDataStack: CoreDataStack
    private var context: NSManagedObjectContext {
        coreDataStack.context
    }
    
    //    var errorStream = PassthroughSubject<any Error, Never> {
    //
    //    }()
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: Save
    
    func saveSessionPublisher(lanDevices: [LanDeviceModel], btDevices: [BluetoothDeviceModel]) -> AnyPublisher<Void, Error> {
        
        let ctx = coreDataStack.context
        
        return Deferred {
            Future<Void, Error> { [weak self] promise in
                guard let self else {
                    let error = NSError(domain: "ScanSessionRepository",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Deallocated"])
                    promise(.failure(error))
                    return
                }
                
                ctx.perform {
                    let session = ScanSession(context: ctx)
                    session.id = UUID()
                    session.timeStamp = Date()
                    
                    for lan in lanDevices {
                        let entity = LanDeviceEntity(context: ctx)
                        entity.name = lan.name
                        entity.ip = lan.ipAdress
                        entity.mac = lan.macAddress
                        entity.scanSession = session
                    }
                    
                    for bt in btDevices {
                        let entity = BluetoothDeviceEntity(context: ctx)
                        entity.uuid = UUID(uuidString: bt.uuid)
                        entity.name = bt.name
                        entity.rssi = Int32(bt.rssi)
                        entity.status = bt.state
                        entity.scanSession = session
                    }
                    
                    do {
                        try self.coreDataStack.saveContext(ctx)
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveSession(lanDevices: [LanDeviceModel], btDevices: [BluetoothDeviceModel]) throws {
        let context = context
        
        let session = ScanSession(context: context)
        session.id = UUID()
        session.timeStamp = Date()
        
        // LAN
        for lan in lanDevices {
            let entity = LanDeviceEntity(context: context)
            entity.name = lan.name
            entity.ip = lan.ipAdress
            entity.mac = lan.macAddress
            entity.scanSession = session
        }
        
        // BT
        for bt in btDevices {
            let entity = BluetoothDeviceEntity(context: context)
            entity.uuid = UUID(uuidString: bt.uuid)
            entity.name = bt.name
            entity.rssi = Int32(bt.rssi)
            entity.status = bt.state
            entity.scanSession = session
        }
        try coreDataStack.saveContext(context)
    }
    
    // MARK: Fetch sessions
    
    func fetchSessions(sort: SessionsSortOption, searchText: String) throws -> [ScanSession] {
        let request: NSFetchRequest<ScanSession> = ScanSession.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        if !searchText.isEmpty {
            let pLan = NSPredicate(format: "ANY lanDevices.name CONTAINS[cd] %@ OR ANY lanDevices.ip CONTAINS[cd] %@", searchText, searchText)
            let pBt  = NSPredicate(format: "ANY bluetoothDevices.name CONTAINS[cd] %@ OR ANY bluetoothDevices.uuid CONTAINS[cd] %@", searchText, searchText)
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [pLan, pBt]))
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
    
    // MARK: Fetch devices for session
    
    func fetchDevices(session: ScanSession, lanSort: LanSortOption, searchText: String) -> AnyPublisher<([BluetoothDeviceModel],[LanDeviceModel]), Error> {
        let lanPublisher = fetchLanDevices(session: session,sort: lanSort,searchText: searchText)
        let btPublisher = fetchBtDevices(session: session,searchText: searchText)
        
        return Publishers.Zip(btPublisher, lanPublisher)
            .eraseToAnyPublisher()
    }
    
    
    private func fetchLanDevices(session: ScanSession,sort: LanSortOption,searchText: String) -> AnyPublisher<[LanDeviceModel], Error> {
        Deferred {
            Future<[LanDeviceModel], Error> { [weak self] promise in
                guard let self = self else {
                    promise(.failure(NSError(domain: "Deinit", code: -1)))
                    return
                }
                
                self.context.perform {
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
                    
                    do {
                        let entities = try self.context.fetch(request)
                        
                        let models = entities.map { entity in
                            LanDeviceModel(
                                name: entity.name ?? "Имя не указано",
                                ipAdress: entity.ip ?? "IP не указан",
                                macAddress: entity.mac ?? "MAC не указан"
                            )
                        }
                        
                        promise(.success(models))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchBtDevices(session: ScanSession, searchText: String) -> AnyPublisher<[BluetoothDeviceModel], Error> {
        Deferred {
            Future<[BluetoothDeviceModel], Error> { [weak self] promise in
                guard let self = self else {
                    let error = NSError(domain: "ScanSessionRepository",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])
                    promise(.failure(error))
                    return
                }
                
                self.context.perform {
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
                    
                    do {
                        let entities = try self.context.fetch(request)
                        
                        let models = entities.map { entity in
                            BluetoothDeviceModel(
                                name: entity.name ?? "Неизвестное устройство",
                                rssi: Int(entity.rssi),
                                uuid: entity.uuid?.uuidString ?? "UUID не задан",
                                state: entity.status ?? ""
                            )
                        }
                        
                        promise(.success(models))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
