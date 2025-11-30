//
//  AppContainer.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import Foundation
import Combine

final class AppContainer: ObservableObject {
    
    // Низкоуровневый стек
    let coreDataStack = CoreDataStack.shared
    
    // Репо
    lazy var scanSessionRepository: ScanSessionRepositoryProtocol = {
        ScanSessionRepository(coreDataStack: coreDataStack)
    }()
    
    lazy var bluetoothRepository: BluetoothRepositoryProtocol = {
        BluetoothRepository(agent: bluetoothAgent)
    }()
    
    lazy var lanRepository: LanRepositoryProtocol = {
        LanRepository(agent: lanAgent)
    }()
    
    // Агенты
    lazy var bluetoothAgent: BluetoothAgentProtocol = BluetoothAgent()
    lazy var lanAgent: NetworkAgentProtocol = NetworkAgent()
    
    // Фабрики ViewModel
    
    func makeScannerViewModel() -> ScannerViewModel {
        ScannerViewModel(scanSessionRepository: scanSessionRepository,
                         btRepository: bluetoothRepository,
                         lanRepository: lanRepository)
    }
    
    func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(repository: scanSessionRepository)
    }
    
    func makeSessionDetailViewModel(session: ScanSession) -> SessionDetailViewModel {
        SessionDetailViewModel(
            session: session,
            repository: scanSessionRepository
        )
    }
}
