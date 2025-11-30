//
//  HistoryView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sessions, id: \.objectID) { session in
                    NavigationLink {
                        SessionDetailCardView(session: session)
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(session.timeStamp ?? Date(), style: .date)
                                Text(session.timeStamp ?? Date(), style: .time)
                            }
                            Text("LAN: \((session.lanDevices as? Set<LanDeviceEntity>)?.count ?? 0)")
                            Text("BT: \((session.bluetoothDevices as? Set<BluetoothDeviceEntity>)?.count ?? 0)")
                        }
                    }
                }
            }
            .onAppear {
                viewModel.reloadSessions()
            }
            .refreshable {
                viewModel.reloadSessions()
            }
            .navigationTitle("Сессии")
            .toolbar {
                Menu {
                    Picker("Сортировка", selection: $viewModel.sortOption) {
                        ForEach(SessionsSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
    }
}

