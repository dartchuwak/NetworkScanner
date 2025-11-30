//
//  HistoryViewModel.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import Foundation
import Combine

final class HistoryViewModel: ObservableObject {
    
    @Published private(set) var sessions: [ScanSession] = []
    @Published var sortOption: SessionsSortOption = .dateDesc
    @Published var searchText: String = ""
    
    private let repository: ScanSessionRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: ScanSessionRepositoryProtocol) {
        self.repository = repository
        setupBindings()
        reloadSessions()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest($sortOption, $searchText)
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
                self?.reloadSessions()
            }
            .store(in: &cancellables)
    }
    
    func reloadSessions() {
        do {
            sessions = try repository.fetchSessions(sort: sortOption)
        } catch {
            print("Ошибка загрузки сессий: \(error)")
            sessions = []
        }
    }
}
