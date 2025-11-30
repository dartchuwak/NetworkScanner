//
//  DeviceCardView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI

struct BluetoothDeviceCardView: View {
    var device: BluetoothDeviceModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(device.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Spacer()
                
                Text("RSSI: \(device.rssi)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("UUID: \(device.uuid)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("Статус: \(device.state)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.top, 5)
    }
}
