//
//  LanError.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 30.11.2025.
//

import Foundation

enum LanError: LocalizedError {
    case unauthorized
    case unsupported
    case unknownState
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Приложению не разрешён доступ к  LAN. Проверьте настройки приватности."
        case .unsupported:
            return "LAN не поддерживается на этом устройстве."
        case .unknownState:
            return "Неизвестное состояние LAN."
        }
    }
}
