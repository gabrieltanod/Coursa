//
//  CoursaApp.swift
//  Coursa
//
//  Created by Gabriel Tanod on 13/10/25.
//

import SwiftUI

@main
struct CoursaApp: App {
    
    @StateObject private var router = AppRouter()
    
    
    // Watch Connectivity
//    @StateObject private var syncService = SyncService()
//    @StateObject private var planManager = PlanManager()
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(router)
                .environment(\.colorScheme, .dark)
            
            
            // Watch Connectivity
//            WatchConnectDisplay()
//            PlanConnectDisplay()
//                .environmentObject(syncService)
//                .environmentObject(planManager)
        }
    }
}
