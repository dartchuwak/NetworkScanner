//
//  AppContainer.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import Foundation
import Combine

final class AppContainer: ObservableObject {
    
    let coreDataStack = CoreDataStack.shared
    
    lazy var bluetoothAgent: BluetoothAgentProtocol = BluetoothAgent()
    lazy var networkAgent: NetworkAgentProtocol = NetworkAgent()
    
    lazy var scannerViewModel: ScannerViewModel = {
        ScannerViewModel(
            btAgent: bluetoothAgent,
            lanAgent: networkAgent,
            coreDataStack: coreDataStack
        )
    }()
}
