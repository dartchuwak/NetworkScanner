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
        VStack {
            Text(device.id)
            Text(device.name)
            Text(device.macAddress)
        }
    }
}

#Preview {
    LanDeviceDetailView(device: LanDeviceModel(name: "TV", ipAdress: "192.168.1.1", macAddress: "00:1B:44:11:3A:B7"))
}
