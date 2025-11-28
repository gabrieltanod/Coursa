//
//  RunningSummaryCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 10/11/25.
//

import SwiftUI

struct RunningSummaryCard: View {
    
    let run : ScheduledRun
    private var title: String { run.template.name }
    
    private var dateText: String {
        run.date.formatted(
            .dateTime
                .weekday(.abbreviated)
                .day(.defaultDigits)
                .month(.abbreviated)
                .year()
                .hour()
                .minute()
        )
    }
    
    private var distanceKm: Double {
        run.actual.distanceKm ?? run.template.targetDistanceKm ?? 0
    }
    
    private var durationSec: Int {
        run.actual.elapsedSec ?? run.template.targetDurationSec ?? 0
    }
    
    private var avgPaceSecPerKm: Int {
        guard distanceKm > 0 else { return 0 }
        return Int(Double(durationSec) / distanceKm)
    }
    private var formattedDistance: String { String(format: "%.2f km", distanceKm) }
    
    private var formattedDuration: String {
        let hours = durationSec / 3600
        let minutes = (durationSec % 3600) / 60
        let seconds = durationSec % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private var formattedAvgHR: String {
        String("\(run.actual.avgHR ?? 0) bpm")
    }
    
    private var formattedPace: String {
        guard avgPaceSecPerKm > 0 else { return "-" }
        let minutes = avgPaceSecPerKm / 60
        let seconds = avgPaceSecPerKm % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var columns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [GridItem(.flexible())]
        } else {
            return [GridItem(.flexible()), GridItem(.flexible())]
        }
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Helvetica Neue", size: 34))
                    .fontWeight(.medium)
                    .foregroundColor(Color("white-500"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.4)
                
                Text(dateText)
                    .font(.custom("Helvetica Neue", size: 17))
                    .fontWeight(.regular)
                    .foregroundStyle(Color("black-100"))
            }
            .padding(.bottom, 10)
            
            LazyVGrid(columns: columns, spacing: 24) {
                StatCell(title: "Duration", value: formattedDuration)
                StatCell(title: "Distance", value: formattedDistance)
                StatCell(title: "Average Pace", value: formattedPace)
                StatCell(title: "Average HR", value: formattedAvgHR)
                
            }
        }
    }
}

struct StatCell: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("Helvetica Neue", size: 17, relativeTo: .body))
                .fontWeight(.regular)
                .foregroundStyle(Color("white-500"))
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            
            Text(value)
                .font(.custom("Helvetica Neue", size: 28, relativeTo: .title))
                .fontWeight(.medium)
                .foregroundStyle(Color("green-400"))
                .lineLimit(1)
                .minimumScaleFactor(0.4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
