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
    
    var body: some Scene {
        WindowGroup { 
            AppRootView()
                .environmentObject(router)
        }
    }
}
