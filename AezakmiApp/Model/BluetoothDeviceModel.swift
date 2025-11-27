//
//  BluetoothDeviceModel.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import Foundation
import CoreBluetooth

struct BluetoothDeviceModel: Hashable, Identifiable {
    
    
    let name: String
    let rssi : Int
    let uuid: UUID
    let status: BluetoothDeviceStatus
    
    var id: UUID { uuid }
    
    init(name: String, rssi: Int, uuid: UUID, peripheralState: CBPeripheralState) {
        self.name = name
        self.rssi = rssi
        self.uuid = uuid
        self.status = BluetoothDeviceStatus(peripheralState: peripheralState)
    }
    
    static func == (lhs: BluetoothDeviceModel, rhs: BluetoothDeviceModel) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
}

enum BluetoothDeviceStatus: String {
    case connected = "Подключено"
    case disconnected = "Ожидание подключения"
    case connecting = "Подключение"
    case disconnecting = "Отключение"
    
    // Функция для инициализации из CBPeripheralState
    init(peripheralState: CBPeripheralState) {
        switch peripheralState {
        case .connected:
            self = .connected
        case .disconnected:
            self = .disconnected
        case .connecting:
            self = .connecting
        case .disconnecting:
            self = .disconnecting
        @unknown default:
            self = .disconnected  // Стандартный статус для неизвестных состояний
        }
    }
}
