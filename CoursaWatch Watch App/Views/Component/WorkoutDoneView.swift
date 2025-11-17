//
//  WorkoutDoneView.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 17/11/25.
//

import SwiftUI

enum WorkoutDoneType: String, CaseIterable, Codable {
    case finishedInZone
    case finishedOutOfZone
    case notFinished
    
    var displayMessage: String {
        switch self {
        case .finishedInZone: return "Goal achieved!"
        case .finishedOutOfZone: return "You pushed a \n bit too hard!"
        case .notFinished: return "Great effort, keep going!"
        }
    }
    
    var displayBg: LinearGradient {
        let colors: [Color]
        switch self {
        case .finishedInZone:
            colors = [Color("wod1-1"), Color("wod1-2")]
        case .finishedOutOfZone:
            colors = [Color("wod2-1"), Color("wod2-2")]
        case .notFinished:
            colors = [Color("wod3-1"), Color("wod3-2")]
        }
          
        return LinearGradient(
            gradient: Gradient(stops: [
                .init(color: colors[0], location: 0.1556),
                .init(color: colors[1], location: 1.114)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct WorkoutDoneView: View {
    let type: WorkoutDoneType
    var body: some View {
        VStack(spacing: 4) {
            Text("Workout Done")
                .font(.helveticaNeue(size: 13, weight: .regular))
            Text(type.displayMessage)
                .font(.helveticaNeue(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Circle()
                .fill(type.displayBg)
        )
        .background(Color("app"))
        .transition(.slide)
    }
    
}

#Preview {
    WorkoutDoneView(type: .notFinished)
}
