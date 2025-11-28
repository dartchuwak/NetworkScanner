//
//  SessionDetailsViewModel.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import Foundation
import Combine

final class SessionDetailViewModel: ObservableObject {
    
    @Published var filter: DeviceTypeSort = .all
    @Published var lanSort: LanSortOption = .name
    @Published var searchText: String = ""
    
    @Published private(set) var lanDevices: [LanDeviceEntity] = []
    @Published private(set) var btDevices: [BluetoothDeviceEntity] = []
    
    private let repository: ScanSessionRepositoryProtocol
    private let session: ScanSession
    private var cancellables = Set<AnyCancellable>()
    
    init(session: ScanSession,
         repository: ScanSessionRepositoryProtocol) {
        self.session = session
        self.repository = repository
        
        setupBindings()
        reloadDevices()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest3($filter, $lanSort, $searchText)
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.reloadDevices()
            }
            .store(in: &cancellables)
    }
    
    private func reloadDevices() {
        do {
            let result = try repository.fetchDevices(
                for: session,
                lanSort: lanSort,
                searchText: searchText
            )
            lanDevices = result.lan
            btDevices  = result.bt
        } catch {
            print("Ошибка загрузки устройств: \(error)")
            lanDevices = []
            btDevices = []
        }
    }
}
