//
//  ButtonControlView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

enum RunningType: String, CaseIterable, Codable {
    case easyRun
    case mafTraining
    case longRun
    
    var displayName: String {
        switch self {
        case .easyRun:
            return "Easy Run"
        case .mafTraining:
            return "MAF Training"
        case .longRun:
            return "Long Run"
        }
    }
    
    var displayGradient: LinearGradient {
        let colors: [Color]
        let stops: [Gradient.Stop]
        let startPoint: UnitPoint
        let endPoint: UnitPoint
        
        switch self {
            
        case .easyRun:
            colors = [Color("er1"), Color("er2")]
            stops = [
                .init(color: colors[0], location: 0.1556),
                .init(color: colors[1], location: 1.114)
            ]
            startPoint = .topLeading
            endPoint = .bottomTrailing
            
        case .mafTraining:
            colors = [Color("maf1"), Color("maf2")]
            stops = [
                .init(color: colors[0], location: 0.1556),
                .init(color: colors[1], location: 1.114)
            ]
            startPoint = .topLeading
            endPoint = .bottomTrailing
            
        case .longRun:
            colors = [Color("lr1"), Color("lr2")]
            stops = [
                .init(color: colors[0], location: 0.1556),
                .init(color: colors[1], location: 1.114)
            ]
            startPoint = .topLeading
            endPoint = .bottomTrailing
        }
        
        return LinearGradient(
            stops: stops,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
    
}

struct PlanCardView: View {
    let date : Date
    let targetDistance: String
    let intensity: String
    let runningType: RunningType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(formatDate(date))
                .font(.helveticaNeue(size: 13, weight: .regular))
                .foregroundColor(Color("primary"))
            
            Text(runningType.displayName)
                .font(.helveticaNeue(size: 20, weight: .bold))
                .foregroundColor(Color("primary"))
            
            Text("\(targetDistance) - \(intensity)")
                .font(.helveticaNeue(size: 14, weight: .regular))
                .foregroundColor(Color("primary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(runningType.displayGradient)
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yy"
        return formatter.string(from: date)
    }
}

#Preview {
    PlanCardView(date: Date(), targetDistance: "3km", intensity: "HR Zone 2", runningType: .longRun)
}

