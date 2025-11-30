//
//  ScanError.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 30.11.2025.
//

import Foundation

enum ScanError: LocalizedError, Identifiable {
    case bluetooth(BluetoothError)
    case lan(LanError)

    var id: String {
        switch self {
        case .bluetooth(let error):
            return "bt-\(String(describing: error))"
        case .lan(let error):
            return "lan-\(String(describing: error))"
        }
    }

    var title: String {
        switch self {
        case .bluetooth:
            return "Ошибка Bluetooth"
        case .lan:
            return "Ошибка сети"
        }
    }

    var errorDescription: String? {
        switch self {
        case .bluetooth(let error):
            return error.errorDescription
        case .lan(let error):
            return error.errorDescription
        }
    }
}
