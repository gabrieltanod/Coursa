//
//  RunningSummaryCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 10/11/25.
//

import SwiftUI

struct RunningSummaryCard: View {

    let run : ScheduledRun
        
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
    private var title: String { run.template.name }

    private var dateText: String {
        run.date.formatted(
            .dateTime
                .weekday(.abbreviated)
                .day(.defaultDigits)
                .month(.abbreviated)
        )
    }

    private var distanceKm: Double {
        run.actual.distanceKm ?? run.template.targetDistanceKm ?? 0
    }

    private var durationSec: Int {
        run.actual.elapsedSec ?? run.template.targetDurationSec ?? 0
    }

    private var avgPaceSecPerKm: Int {
        if let p = run.actual.avgPaceSecPerKm { return p }
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

    private var formattedPace: String {
        guard avgPaceSecPerKm > 0 else { return "-" }
        let minutes = avgPaceSecPerKm / 60
        let seconds = avgPaceSecPerKm % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }
    
    var body: some View {
        VStack(alignment:.leading) {
            VStack (alignment: .leading){
                Text(title)
                    .font(.custom("Helvetica Neue", size: 34))
                    .fontWeight(.medium)
                    .foregroundStyle(Color("white-500"))
                Text(dateText)
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
                    Text(formattedDuration)
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
                    Text(formattedDistance)
                        .font(.custom("Helvetica Neue", size: 28))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("green-400"))
                }
            }
            .padding([.top, .horizontal],16)

            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Average Pace")
                        .font(.custom("Helvetica Neue", size: 15))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("white-500"))
                    Text(formattedPace)
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
}
