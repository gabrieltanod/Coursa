//
//  CoursaApp.swift
//  Coursa
//
//  Created by Gabriel Tanod on 13/10/25.
//

import SwiftUI

@main
struct CoursaApp: App {

    // route main ios gua comment buat test watchconnectivity
    
    //    @StateObject private var router = AppRouter()
    @StateObject private var syncService = SyncService()
    
    var body: some Scene {
        WindowGroup {
            //            AppRootView()
            //                .environmentObject(router)
            WatchConnectDisplay()
//            PlanConnectDisplay()
                .environmentObject(syncService)
        }
    }
}
