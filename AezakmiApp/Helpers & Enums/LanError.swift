//
//  LanError.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 30.11.2025.
//

import Foundation

enum LanError: LocalizedError, Identifiable {
    case unauthorized
    case unsupported
    case unknownState
    case netoworkNotAvailable
    case wifiNotConnected
    
    var id: String { localizedDescription }
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Приложению не разрешён доступ к  LAN. Проверьте настройки приватности."
        case .unsupported:
            return "LAN не поддерживается на этом устройстве."
        case .unknownState:
            return "Неизвестное состояние LAN."
        case .netoworkNotAvailable:
            return "Нет доступо к сети"
        case .wifiNotConnected:
            return "WiFI не подключен"
        }
    }
}
