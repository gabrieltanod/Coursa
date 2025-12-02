//
//  CoreTabView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 03/11/25.
//

import SwiftUI

struct CoreTabView: View {
    let onboardingData: OnboardingData
    @AppStorage("selectedTab") private var selectedTab: Int = 0
    @EnvironmentObject var planSession: PlanSessionStore
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Plan", systemImage: "chart.bar.fill")
            }
            .tag(0)

            NavigationStack {
                StatisticsView(viewModel: StatisticsViewModel(planSession: planSession))
            }
            .tabItem {
                Label("Statistics", systemImage: "square.grid.2x2.fill")
            }
            .tag(1)
            
            NavigationStack {
                SettingsView(viewModel: SettingsViewModel(router: router, planSession: planSession))
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(2)
        }
        .tint(Color("green-500"))
    }
}
