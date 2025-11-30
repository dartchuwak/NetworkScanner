//
//  LanDeviceDetailView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 29.11.2025.
//

import SwiftUI

struct LanDeviceDetailView: View {
    let device: LanDeviceModel
    var body: some View {
        VStack(alignment: .leading) {
            Text("IP-адрес устройства: \(device.ipAdress)")
            Text("Имя устройства: \(device.name)")
            Text("MAC-адрес устройства: \(device.macAddress)")
        }
    }
}

#Preview {
    LanDeviceDetailView(device: LanDeviceModel(name: "TV", ipAdress: "192.168.1.1", macAddress: "00:1B:44:11:3A:B7"))
}
