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
    func saveSessionAsync(lanDevices: [LanDeviceModel], btDevices: [BluetoothDeviceModel]) async throws
    func fetchSessions(sort: SessionsSortOption) throws -> [ScanSession]
    func fetchDevices(session: ScanSession, lanSort: LanSortOption, searchText: String) -> AnyPublisher<([BluetoothDeviceModel],[LanDeviceModel]), Error>
}

final class ScanSessionRepository: ScanSessionRepositoryProtocol {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Save
    func saveSessionAsync(lanDevices: [LanDeviceModel], btDevices: [BluetoothDeviceModel]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackground { ctx in
                do {
                    let session = ScanSession(context: ctx)
                    session.id = UUID()
                    session.timeStamp = Date()
                    
                    // LAN
                    for lan in lanDevices {
                        let entity = LanDeviceEntity(context: ctx)
                        entity.name = lan.name
                        entity.ip = lan.ipAddress
                        entity.mac = lan.macAddress
                        entity.scanSession = session
                    }
                    
                    // BT
                    for bt in btDevices {
                        let entity = BluetoothDeviceEntity(context: ctx)
                        entity.uuid = UUID(uuidString: bt.uuid)
                        entity.name = bt.name
                        entity.rssi = Int32(bt.rssi)
                        entity.status = bt.state
                        entity.scanSession = session
                    }
                    
                    if ctx.hasChanges {
                        try ctx.save()
                    }
                    
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Fetch sessions
    func fetchSessions(sort: SessionsSortOption) throws -> [ScanSession] {
        let request: NSFetchRequest<ScanSession> = ScanSession.fetchRequest()
        
        switch sort {
        case .dateDesc:
            request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        case .dateAsc:
            request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: true)]
        }
        let scanSession = try coreDataStack.viewContext.fetch(request)
        
        return scanSession
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
                
                coreDataStack.viewContext.perform {
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
                        let entities = try self.coreDataStack.viewContext.fetch(request)
                        
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
                
                self.coreDataStack.viewContext.perform {
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
                        let entities = try self.coreDataStack.viewContext.fetch(request)
                        
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
