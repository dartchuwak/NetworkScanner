//
//  ContentView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI

struct ScannerView: View {
    @StateObject var btViewModel = ScannerViewModel()
    @State var isScanActive: Bool = false
    @State private var picker: DeviceType = .bt
    
    var body: some View {
        NavigationView {
            ZStack {
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
                                ForEach(btViewModel.devices) { device in
                                    DeviceCardView(device: device)
                                }
                                
                            } else {
                                ForEach(btViewModel.devices) { device in
                                    DeviceCardView(device: device)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Поиск")
                
                VStack {
                    Spacer()
                    
                    Button {
                        btViewModel.startScanning()
                    } label: {
                        Text("Начать сканирование")
                            .font(.headline)
                            .frame(width: 250, height: 50)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(25)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 40)
                }
                
                if btViewModel.isScanActive {
                    ProgressView()
                        .scaleEffect(1)
                }
            }
        }
    }
}

#Preview {
    ScannerView()
}
