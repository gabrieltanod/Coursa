//
//  ContentView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 24/10/25.
//

import SwiftUI

struct SummaryPageView: View {
    @State private var timeElapsed: Double = 0.0
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    @State private var selectedHorizontalTab = 1
    @State private var selectedVerticalTab = 0
    @State private var hasStarted: Bool = false
    @Binding var appState: AppState
    
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
                SummaryDistanceView()
                    .tag(0)
                
                // Halaman 2: Heart Rate
                SummaryHRView()
                    .tag(1)
                
                // Halaman 3: Pace
                SummaryPaceElevationView()
                    .tag(2)
            }
            .tabViewStyle(.verticalPage)
            
        }
        .ignoresSafeArea()
        
    }
}

#Preview {
    SummaryPageView(appState: .constant(.summary))
}
