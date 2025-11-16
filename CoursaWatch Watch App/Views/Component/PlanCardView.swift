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
        case .easyRun: return "Easy Run"
        case .mafTraining: return "MAF Training"
        case .longRun: return "Long Run"
        }
    }
    
    var displayGradient: LinearGradient {
        let colors: [Color]
        switch self {
        case .easyRun:
            colors = [Color("er1"), Color("er2")]
        case .mafTraining:
            colors = [Color("maf1"), Color("maf2")]
        case .longRun:
            colors = [Color("lr1"), Color("lr2")]
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
    
    init(from runKind: RunKind?) {
        switch runKind {
        case .easy: self = .easyRun
        case .maf: self = .mafTraining
        case .long: self = .longRun
        default: self = .easyRun  // fallback
        }
    }
}

struct PlanCardView: View {
    
    let plan: ScheduledRun
    
    var runningType: RunningType {
        RunningType(from: plan.template.kind)
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(formatDate(plan.date))
                .font(.helveticaNeue(size: 13, weight: .regular))
                .foregroundColor(Color("primary"))
            
            Text(plan.template.name)
                .font(.helveticaNeue(size: 20, weight: .bold))
                .foregroundColor(Color("primary"))
            
//            Text("\(plan.template.targetDistanceKm) - \(plan.template.targetHRZone)")
            Text("\(plan.subtitle)")
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
