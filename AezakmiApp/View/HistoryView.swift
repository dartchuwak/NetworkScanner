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
                        SessionDetailEntryView(session: session)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(session.timeStamp ?? Date(), style: .date)
                            Text("LAN: \((session.lanDevices as? Set<LanDeviceEntity>)?.count ?? 0)")
                            Text("BT: \((session.bluetoothDevices as? Set<BluetoothDeviceEntity>)?.count ?? 0)")
                        }
                    }
                }
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
            .searchable(text: $viewModel.searchText,
                        prompt: "Имя / IP / UUID")
        }
    }
}

struct SessionDetailEntryView: View {
    @EnvironmentObject var container: AppContainer
    let session: ScanSession
    
    var body: some View {
        SessionDetailView(
            viewModel: container.makeSessionDetailViewModel(session: session)
        )
    }
}
