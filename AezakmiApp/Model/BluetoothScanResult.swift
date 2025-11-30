//
//  BluetoothScanResult.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 30.11.2025.
//

import Foundation
import CoreBluetooth

struct BluetoothScanResult {
    let peripheral: CBPeripheral
    let rssi: Int
}
