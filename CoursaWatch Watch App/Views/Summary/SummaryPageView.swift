//
//  SummaryPageView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 24/10/25.
//

import SwiftUI

struct SummaryPageView: View {
    @State private var selectedVerticalTab = 0
    
    @Binding var appState: AppState
    @ObservedObject var viewModel: SummaryPageViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Button(action: {
                appState = .planning
            }) {
                Image(systemName: "xmark")
                    .font(.callout.weight(.bold))
                    .padding(8)
                    .background(Color.gray.opacity(0.4))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding([.top, .leading], 15)
            .zIndex(1) 
            
            TabView(selection: $selectedVerticalTab) {
                // Halaman 1: Overview
                SummaryDistanceView(viewModel: viewModel)
                    .tag(0)
                
                // Halaman 2: Heart Rate
                SummaryHRView(viewModel: viewModel)
                    .tag(1)
                
                // Halaman 3: Pace
                SummaryPaceElevationView(viewModel: viewModel)
                    .tag(2)
            }
            .tabViewStyle(.verticalPage)
            
        }
        .ignoresSafeArea()
        
    }
}
