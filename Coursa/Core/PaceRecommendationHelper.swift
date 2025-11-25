//
//  PaceRecommendationHelper.swift
//  Coursa
//
//  Created by Gabriel Tanod on 25/11/25.
//
//  Summary
//  -------
//  Calculates dynamic zone 2 pace recommendations based on user's historical
//  run performance, with a conservative approach to ensure users stay in zone 2.
//
//  Responsibilities
//  ----------------
//  - Calculate recommended pace from recent zone 2 runs
//  - Apply conservative buffer (10-15 seconds) to ensure zone 2 adherence
//  - Handle edge cases (no history, poor zone 2 adherence, new users)
//  - Format pace for display
//

import Foundation

enum PaceRecommendationHelper {
    
    // MARK: - Main Calculation
    
    /// Calculate recommended pace for zone 2 training
    /// - Parameters:
    ///   - referenceDate: Date for context (typically today)
    ///   - plan: The current generated plan with run history
    ///   - onboarding: User onboarding data (optional)
    /// - Returns: Formatted pace string (e.g., "7:30/km")
    static func calculateRecommendedPace(
        for referenceDate: Date = Date(),
        plan: GeneratedPlan,
        onboarding: OnboardingData?
    ) -> String {
        // Filter for completed runs with zone 2 data
        let completedRuns = plan.runs.filter { $0.status == .completed }
        
        // Get recent runs with good zone 2 adherence (>70% time in zone 2)
        let recentZone2Runs = completedRuns
            .filter { timeInZone2Percentage(for: $0) > 0.7 }
            .sorted { $0.date > $1.date }  // Most recent first
            .prefix(5)  // Last 5 quality zone 2 runs
        
        // If no quality zone 2 runs, return conservative fallback
        guard !recentZone2Runs.isEmpty else {
            return "7:30/km"  // Conservative fallback for new users
        }
        
        // Check if any runs have valid distance data
        let hasValidData = recentZone2Runs.contains { run in
            guard let distance = run.actual.distanceKm,
                  let elapsedSec = run.actual.elapsedSec,
                  distance > 0,
                  elapsedSec > 0 else {
                return false
            }
            return true
        }
        
        // If no valid data, return fallback
        guard hasValidData else {
            return "7:30/km"
        }
        
        // Calculate average zone 2 pace from recent runs
        let avgZone2Pace = averageZone2Pace(for: Array(recentZone2Runs))
        
        // Apply conservative buffer: start 10-15 seconds slower
        let conservativeBuffer = 10.0  // seconds per km
        
        // Check if user struggled in their last run (< 50% time in zone 2)
        let extraBuffer: Double
        if let lastRun = completedRuns.sorted(by: { $0.date > $1.date }).first,
           timeInZone2Percentage(for: lastRun) < 0.5 {
            // User struggled to stay in zone 2 - add extra buffer
            extraBuffer = 15.0
        } else {
            extraBuffer = 0.0
        }
        
        let recommendedPaceSecPerKm = avgZone2Pace + conservativeBuffer + extraBuffer
        
        return formatPace(secondsPerKm: recommendedPaceSecPerKm)
    }
    
    // MARK: - Helper Methods
    
    /// Calculate average pace for time spent in zone 2 across multiple runs
    /// - Parameter runs: Array of scheduled runs with zone 2 data
    /// - Returns: Average pace in seconds per kilometer
    private static func averageZone2Pace(for runs: [ScheduledRun]) -> Double {
        var totalWeightedPace: Double = 0
        var totalDistance: Double = 0
        
        for run in runs {
            guard let distance = run.actual.distanceKm,
                  let elapsedSec = run.actual.elapsedSec,
                  distance > 0 else {
                continue
            }
            
            // Calculate pace for this run (seconds per km)
            let paceSecPerKm = Double(elapsedSec) / distance
            
            // Weight by distance (longer runs contribute more to average)
            totalWeightedPace += paceSecPerKm * distance
            totalDistance += distance
        }
        
        guard totalDistance > 0 else {
            // Fallback: 7:30/km = 450 seconds/km
            return 450.0
        }
        
        return totalWeightedPace / totalDistance
    }
    
    /// Calculate percentage of run spent in zone 2
    /// - Parameter run: Scheduled run with zone duration data
    /// - Returns: Percentage (0.0 to 1.0) of time spent in zone 2
    static func timeInZone2Percentage(for run: ScheduledRun) -> Double {
        guard let elapsedSec = run.actual.elapsedSec,
              elapsedSec > 0 else {
            return 0.0
        }
        
        let zone2Seconds = run.actual.zoneDuration[2] ?? 0.0
        return zone2Seconds / Double(elapsedSec)
    }
    
    /// Format pace as "M:SS/km" string
    /// - Parameter secondsPerKm: Pace in seconds per kilometer
    /// - Returns: Formatted string (e.g., "7:30/km")
    static func formatPace(secondsPerKm: Double) -> String {
        let totalSeconds = Int(secondsPerKm.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d/km", minutes, seconds)
    }
}
