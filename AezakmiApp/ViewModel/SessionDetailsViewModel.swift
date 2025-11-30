//
//  SessionDetailsViewModel.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import Foundation
import Combine

final class SessionDetailViewModel: ObservableObject {
    
    @Published var deviceTypeFilter: DeviceType = .lan
    @Published var lanSort: LanSortOption = .name
    @Published var searchText: String = ""
    
    @Published private(set) var lanDevices: [LanDeviceModel] = []
    @Published private(set) var btDevices: [BluetoothDeviceModel] = []
    
    private let repository: ScanSessionRepositoryProtocol
    private let session: ScanSession
    private var cancellables = Set<AnyCancellable>()
    
    init(session: ScanSession, repository: ScanSessionRepositoryProtocol) {
        self.session = session
        self.repository = repository
        setupBindings()
        loadDevices()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest3($deviceTypeFilter, $lanSort, $searchText)
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.loadDevices()
            }
            .store(in: &cancellables)
    }
    
    private func loadDevices() {
        repository.fetchDevices(session: session, lanSort: lanSort, searchText: searchText)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("Finished loading detail session devices")
                case .failure(let error):
                    print("Ошибка загрузки устройств: \(error)")
                    self?.lanDevices = []
                    self?.btDevices = []
                }
                
            } receiveValue: { [weak self] bt, lan in
                self?.btDevices = bt
                self?.lanDevices = lan
            }
            .store(in: &cancellables)
        
    }
}
