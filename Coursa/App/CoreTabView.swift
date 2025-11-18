//
//  CoreTabView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 03/11/25.
//

import SwiftUI

struct CoreTabView: View {
    let onboardingData: OnboardingData
    @StateObject private var planSession = PlanSessionStore()

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    .environmentObject(planSession)
            }
            .tabItem {
                Label("Plan", systemImage: "chart.bar.fill")
            }

            NavigationStack {
                StatisticsView()
                    .environmentObject(planSession)
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
