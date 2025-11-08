//
//  RunningSummary.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 30/10/25.
//

import Foundation

struct WorkoutSummary: Codable, Hashable, Sendable{
    var id = UUID()
    let totalTime: Double
    let totalDistance: Double
    let averageHeartRate: Double
    let averagePace: Double
    let elevationGain: Double
    let zoneDuration: [Int: Double]
}
