//
//  CoursaApp.swift
//  Coursa
//
//  Created by Gabriel Tanod on 13/10/25.
//

import SwiftUI

@main
struct CoursaApp: App {
    
    @StateObject private var router: AppRouter
    @StateObject private var planSession: PlanSessionStore

    // Watch Connectivity
    @StateObject private var syncService: SyncService
    @StateObject private var planManager: PlanManager

    init() {
        let router = AppRouter()
        let planSession = PlanSessionStore()
        let planManager = PlanManager.shared
        let syncService = SyncService(planSession: planSession)

        _router = StateObject(wrappedValue: router)
        _planSession = StateObject(wrappedValue: planSession)
        _planManager = StateObject(wrappedValue: planManager)
        _syncService = StateObject(wrappedValue: syncService)

        // Wire dependencies so everyone shares the same instances
        planManager.syncService = syncService
        planManager.planSession = planSession
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(router)
                .environmentObject(planManager)
                .environmentObject(syncService)
                .environmentObject(planSession)
                .environment(\.colorScheme, .dark)
            
            
            
            // Watch Connectivity
//            WatchConnectivityDebugView()
//                .environmentObject(syncService)
//                .environmentObject(planManager)

        }
    }
}
