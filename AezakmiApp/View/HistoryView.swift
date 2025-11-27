//
//  HistoryView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI

struct HistoryView: View {
    @State private var picker: DeviceType = .bt
    
    var body: some View {
  
        NavigationView {
            VStack {
                Picker("Вид устройства", selection: $picker) {
                    ForEach(DeviceType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                ScrollView {
                    VStack {
                        if picker == .bt {
                            Text("Bluetooth Devices")
                                .font(.title)
                                .padding()
                            // Добавьте сюда код для отображения истории Bluetooth-устройств
                        } else {
                            Text("LAN Devices")
                                .font(.title)
                                .padding()
                            // Добавьте сюда код для отображения истории LAN-устройств
                        }
                    }
                }
            }
            .navigationTitle("История")
        }
    }
}

#Preview {
    HistoryView()
}
