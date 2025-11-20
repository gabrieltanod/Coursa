//
//  CoreTabView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 03/11/25.
//

import SwiftUI

struct CoreTabView: View {
    let onboardingData: OnboardingData
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Plan", systemImage: "chart.bar.fill")
            }

            NavigationStack {
                StatisticsView()
            }
            .tabItem {
                Label("Statistics", systemImage: "square.grid.2x2.fill")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(Color("green-500"))
    }
}
