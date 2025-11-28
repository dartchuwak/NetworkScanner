//
//  LanDeviceCardView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import SwiftUI

struct LanDeviceCardView: View {
    var device: LanDeviceModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(device.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text("IP: \(device.ipAdress)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("MAC: \(device.macAddress)")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

#Preview {
    LanDeviceCardView(device: LanDeviceModel(name: "Неизвестное устройство", ipAdress: "192.168.1.100", macAddress: "00:1A:7D:DA:71:13", id: "1"))
}
