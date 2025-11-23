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
        let colors: [Color] = [Color("grey-gradient2"), Color("black-gradient2")]
        return LinearGradient(
            gradient: Gradient(stops: [
                .init(color: colors[0], location: 0.0921),
                .init(color: colors[1], location: 0.4825)
            ]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
    }
    private var title: String { run.template.name }
    
    private var dateText: String {
        run.date.formatted(
            .dateTime
                .weekday(.abbreviated)
                .day(.defaultDigits)
                .month(.abbreviated)
                .year()
        )
    }
    
    private var distanceKm: Double {
        run.actual.distanceKm ?? run.template.targetDistanceKm ?? 0
    }
    
    private var durationSec: Int {
        run.actual.elapsedSec ?? run.template.targetDurationSec ?? 0
    }
    
    private var avgPaceSecPerKm: Int {
//        if let p = run.actual.avgPaceSecPerKm { return p }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) { // Spacing antar baris informasi
            // Header Card
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Helvetica Neue", size: 34))
                    .fontWeight(.medium)
                    .foregroundStyle(Color("white-500"))
                Text(dateText)
                    .font(.custom("Helvetica Neue", size: 17))
                    .fontWeight(.regular)
                    .foregroundStyle(Color("black-100"))
            }
            .padding(.bottom, 10) // Jarak bawah header
            
            // Grid untuk Durasi, Jarak, HR, Pace
            // Menggunakan LazyVGrid untuk layout 2 kolom
            LazyVGrid(columns:
                        [GridItem(.flexible(), alignment: .leading),
                         GridItem(.flexible(), alignment: .leading)
                        ], spacing: 16) {
                // Durasi
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
                
                // Jarak
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
                
                // Average HR
                VStack(alignment: .leading) {
                    Text("Average HR")
                        .font(.custom("Helvetica Neue", size: 15))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("white-500"))
                    Text(formattedAvgHR)
                        .font(.custom("Helvetica Neue", size: 28))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("green-400"))
                }
                
                // Average Pace
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
        }
//        .padding(16) // Padding internal card
//        .background(gradient) // Background gradient yang Anda berikan
//        .cornerRadius(20) // Sudut membulat pada card
//        .shadow(radius: 5) // Bayangan kecil untuk kedalaman
        
    }
}
