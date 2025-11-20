//
//  CoursaWatchApp.swift
//  CoursaWatch Watch App
//
//  Created by Gabriel Tanod on 23/10/25.
//
import SwiftUI

@main
struct CoursaWatch_Watch_AppApp: App {
    @StateObject private var syncService = SyncService.shared
    @StateObject private var workoutManager = WorkoutManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(syncService)
                .environmentObject(workoutManager)
        }
    }
}
