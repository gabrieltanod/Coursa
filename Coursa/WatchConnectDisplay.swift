//
//  WatchConnectDisplay.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 05/11/25.
//

import Foundation
import SwiftUI

struct WatchConnectDisplay: View {
    
    @StateObject private var connectivityService = ConnectivityService.shared
    
    var body: some View {
        VStack {
            Text("iOS App")
            
            if let summary = connectivityService.receivedSummary {
                Text("New Summary Received!")
                Text("Total Time: \(String(describing: summary.totalTime))")
                Text("Avg HR: \(String(describing: summary.averageHeartRate))")
            } else {
                Text("Waiting for data from Apple Watch...")
            }
        }
        .onAppear {
            print("iOS: ContentView appeared, service is listening.")
        }
    }
}

