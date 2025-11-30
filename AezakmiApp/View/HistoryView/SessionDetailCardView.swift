//
//  SessionDetailCardView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 30.11.2025.
//

import SwiftUI

struct SessionDetailCardView: View {
    @EnvironmentObject var container: AppContainer
    let session: ScanSession
    
    var body: some View {
        SessionDetailView(viewModel: container.makeSessionDetailViewModel(session: session), sessionDate: session.timeStamp ?? Date())
    }
}
