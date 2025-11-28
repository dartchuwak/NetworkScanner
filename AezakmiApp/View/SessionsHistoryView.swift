//
//  HistoryView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI

struct SessionsHistoryView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(sortDescriptors: [SortDescriptor(\ScanSession.timeStamp, order: .reverse)])
    private var sessions: FetchedResults<ScanSession>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sessions, id: \.objectID) { session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(session.timeStamp ?? Date(), style: .date)
                            Text("LAN: \((session.lanDevices as? Set<LanDeviceEntity>)?.count ?? 0)")
                            Text("BT: \((session.bluetoothDevices as? Set<BluetoothDeviceEntity>)?.count ?? 0)")
                        }
                    }
                }
            }
            .navigationTitle("Scan Sessions")
        }
    }
}
