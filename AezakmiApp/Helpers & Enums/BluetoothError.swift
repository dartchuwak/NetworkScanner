//
//  BluetoothError.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 30.11.2025.
//

import Foundation

enum BluetoothError: LocalizedError {
    case poweredOff
    case unauthorized
    case unsupported
    case unknownState
    
    var errorDescription: String? {
        switch self {
        case .poweredOff:
            return "Bluetooth выключен. Включите Bluetooth в настройках устройства."
        case .unauthorized:
            return "Приложению не разрешён доступ к Bluetooth. Проверьте настройки приватности."
        case .unsupported:
            return "Bluetooth не поддерживается на этом устройстве."
        case .unknownState:
            return "Неизвестное состояние Bluetooth."
        }
    }
}
