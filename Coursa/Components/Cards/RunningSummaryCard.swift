//
//  RunningSummaryCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 10/11/25.
//

import SwiftUI

struct RunningSummaryCard: View {

    var gradient: LinearGradient {
        let _: [Color] = [Color("black-gradient"), Color("gray-gradient")]
        let stops: [Gradient.Stop] = [
            .init(color: Color("black-gradient"), location: 0.1312),
            .init(color: Color("gray-gradient"), location: 2.9781),
        ]
        let startPoint: UnitPoint = .init(x: 0.3, y: 0.35)
        let endPoint: UnitPoint = .init(x: 0.75, y: 1.7)

        return LinearGradient(
            stops: stops,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
    
    let run: ScheduledRun
    let summary: RunningSummary
    
    var body: some View {
        VStack(alignment:.leading) {
            VStack (alignment: .leading){
                Text(run.template.name)
                    .font(.custom("Helvetica Neue", size: 34))
                    .fontWeight(.medium)
                    .foregroundStyle(Color("white-500"))
                Text(formatDate(run.date))
                    .font(.custom("Helvetica Neue", size: 17))
                    .fontWeight(.regular)
                    .foregroundStyle(Color("black-100"))
            }
            .padding([.top, .horizontal], 16)

            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.custom("Helvetica Neue", size: 15))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("white-500"))
                    Text(formattedTotalTime)
                        .font(.custom("Helvetica Neue", size: 28))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("green-400"))
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Distance")
                        .font(.custom("Helvetica Neue", size: 15))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("white-500"))
                    Text(String(format: "%.2f KM", summary.totalDistance))
                        .font(.custom("Helvetica Neue", size: 28))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("green-400"))
                }
            }
            .padding([.top, .horizontal],16)

            HStack {
                VStack(alignment: .leading) {
                    Text("Average HR")
                        .font(.custom("Helvetica Neue", size: 15))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("white-500"))
                    Text("\(Int(summary.averageHeartRate)) bpm")
                        .font(.custom("Helvetica Neue", size: 28))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("green-400"))
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Average Pace")
                        .font(.custom("Helvetica Neue", size: 15))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("white-500"))
                    Text("\(formattedPace)/Km")
                        .font(.custom("Helvetica Neue", size: 28))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("green-400"))
                }
            }
            .padding(16)

        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(gradient)
        )

    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yy"
        return formatter.string(from: date)
    }
    
    var formattedTotalTime: String {
        let totalSeconds = Int(summary.totalTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var formattedPace: String {
        // averagePace is in minutes per km, convert to mm:ss format
        let totalSeconds = Int(summary.averagePace * 60)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    let sampleTemplate = RunTemplate(
        id: UUID().uuidString,
        name: "Easy Run",
        kind: .maf,
        focus: .speed
    )
    
    let sampleRun = ScheduledRun(
        id: UUID().uuidString,
        date: Date(),
        template: sampleTemplate
    )
    
    let sampleSummary = RunningSummary(
        totalTime: 3600,
        totalDistance: 7.8,
        averageHeartRate: 145,
        averagePace: 3.0
    )
    
    RunningSummaryCard(run: sampleRun, summary: sampleSummary)
}
