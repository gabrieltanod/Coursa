//
//  OverviewPageViewModels.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 28/10/25.
//

import SwiftUI
import Combine

class OverviewPageViewModel: ObservableObject {
    
    @EnvironmentObject var workoutManager: WorkoutManager
    
    func formattedPace(time: Double) -> String {
        
        
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}
