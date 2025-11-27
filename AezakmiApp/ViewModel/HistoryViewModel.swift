//
//  HistoryViewModel.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import Foundation
import Combine

final class HistoryViewModel: ObservableObject {
    
    @Published var bluetoothDevices: [BluetoothDeviceModel] = []
    @Published var lanDevices: [LanDeviceModel] = []
    
}
