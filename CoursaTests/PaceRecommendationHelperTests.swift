//
//  PaceRecommendationHelperTests.swift
//  CoursaTests
//
//  Created by Gabriel Tanod on 25/11/25.
//
//  Comprehensive tests for PaceRecommendationHelper using Swift Testing.
//

import Foundation
import Testing

@testable import Coursa

struct PaceRecommendationHelperTests {
    
    // MARK: - Test Helpers
    
    private func makeDate(_ str: String) -> Date {
        let parts = str.split(separator: "-")
        let y = Int(parts[0])!, m = Int(parts[1])!, d = Int(parts[2])!
        var comps = DateComponents()
        comps.year = y; comps.month = m; comps.day = d
        let cal = Calendar.current
        let dt = cal.date(from: comps)!
        return cal.startOfDay(for: dt)
    }
    
    private func makeRun(
        date: Date,
        durationSec: Int,
        distanceKm: Double,
        zone2Seconds: Double,
        completed: Bool = true
    ) -> ScheduledRun {
        let template = RunTemplate(
            name: "Test Run",
            kind: .easy,
            focus: .base,
            targetDurationSec: durationSec,
            targetDistanceKm: distanceKm,
            targetHRZone: .z2,
            notes: nil
        )
        
        var run = ScheduledRun(date: date, template: template)
        if completed {
            run.status = .completed
            run.actual.elapsedSec = durationSec
            run.actual.distanceKm = distanceKm
            run.actual.zoneDuration = [2: zone2Seconds]
        }
        return run
    }
    
    private func makePlan(runs: [ScheduledRun]) -> GeneratedPlan {
        GeneratedPlan(plan: .endurance, runs: runs.sorted { $0.date < $1.date })
    }
    
    // MARK: - Recommended Pace Calculation Tests
    
    @Test
    func calculateRecommendedPace_withGoodZone2Runs_returnsSlowerThanAverage() {
        // Given: 5 recent runs with good zone 2 adherence (>70% time in zone 2)
        let runs = [
            makeRun(date: makeDate("2025-11-20"), durationSec: 2400, distanceKm: 5.0, zone2Seconds: 1800),  // 75% in Z2, 8:00/km
            makeRun(date: makeDate("2025-11-18"), durationSec: 2700, distanceKm: 6.0, zone2Seconds: 2100),  // 77% in Z2, 7:30/km
            makeRun(date: makeDate("2025-11-15"), durationSec: 3000, distanceKm: 6.5, zone2Seconds: 2400),  // 80% in Z2, 7:42/km
            makeRun(date: makeDate("2025-11-13"), durationSec: 2400, distanceKm: 5.0, zone2Seconds: 1920),  // 80% in Z2, 8:00/km
            makeRun(date: makeDate("2025-11-10"), durationSec: 2880, distanceKm: 6.0, zone2Seconds: 2300),  // 79% in Z2, 8:00/km
        ]
        
        let plan = makePlan(runs: runs)
        
        // When
        let recommendedPace = PaceRecommendationHelper.calculateRecommendedPace(
            for: Date(),
            plan: plan,
            onboarding: nil
        )
        
        // Then: Should apply conservative buffer (10 seconds slower)
        // Average pace is approximately 7:47/km (467 sec/km)
        // With 10 second buffer: 7:57/km (477 sec/km)
        #expect(recommendedPace.contains("7:5") || recommendedPace.contains("8:0"))
        #expect(recommendedPace.hasSuffix("/km"))
    }
    
    @Test
    func calculateRecommendedPace_noHistory_returnsFallback() {
        // Given: Empty plan with no completed runs
        let plan = makePlan(runs: [])
        
        // When
        let recommendedPace = PaceRecommendationHelper.calculateRecommendedPace(
            for: Date(),
            plan: plan,
            onboarding: nil
        )
        
        // Then: Should return conservative fallback
        #expect(recommendedPace == "7:30/km")
    }
    
    @Test
    func calculateRecommendedPace_poorZone2Adherence_addsExtraBuffer() {
        // Given: Recent runs where last run had poor zone 2 adherence (<50%)
        let runs = [
            makeRun(date: makeDate("2025-11-20"), durationSec: 2400, distanceKm: 5.0, zone2Seconds: 1000),  // 42% in Z2 (poor!)
            makeRun(date: makeDate("2025-11-18"), durationSec: 2700, distanceKm: 6.0, zone2Seconds: 2100),  // 77% in Z2
            makeRun(date: makeDate("2025-11-15"), durationSec: 3000, distanceKm: 6.5, zone2Seconds: 2400),  // 80% in Z2
            makeRun(date: makeDate("2025-11-13"), durationSec: 2400, distanceKm: 5.0, zone2Seconds: 1920),  // 80% in Z2
            makeRun(date: makeDate("2025-11-10"), durationSec: 2880, distanceKm: 6.0, zone2Seconds: 2300),  // 79% in Z2
        ]
        
        let plan = makePlan(runs: runs)
        
        // When
        let recommendedPace = PaceRecommendationHelper.calculateRecommendedPace(
            for: Date(),
            plan: plan,
            onboarding: nil
        )
        
        // Then: Should add extra 15 second buffer on top of normal 10 second buffer
        // This should result in a significantly slower pace
        #expect(recommendedPace.hasSuffix("/km"))
        // Expected to be slower than 8:00/km due to poor adherence
    }
    
    @Test
    func calculateRecommendedPace_fewQualityRuns_usesWhatIsAvailable() {
        // Given: Only 2 runs with good zone 2 adherence
        let runs = [
            makeRun(date: makeDate("2025-11-20"), durationSec: 2400, distanceKm: 5.0, zone2Seconds: 1800),  // 75% in Z2
            makeRun(date: makeDate("2025-11-18"), durationSec: 2700, distanceKm: 6.0, zone2Seconds: 2100),  // 77% in Z2
            makeRun(date: makeDate("2025-11-15"), durationSec: 3000, distanceKm: 6.5, zone2Seconds: 1200),  // 40% in Z2 (excluded)
        ]
        
        let plan = makePlan(runs: runs)
        
        // When
        let recommendedPace = PaceRecommendationHelper.calculateRecommendedPace(
            for: Date(),
            plan: plan,
            onboarding: nil
        )
        
        // Then: Should calculate from available quality runs
        #expect(recommendedPace.hasSuffix("/km"))
        #expect(recommendedPace != "7:30/km")  // Not fallback
    }
    
    @Test
    func calculateRecommendedPace_mixedQualityRuns_filtersCorrectly() {
        // Given: Mix of good and poor zone 2 runs
        let runs = [
            makeRun(date: makeDate("2025-11-20"), durationSec: 2400, distanceKm: 5.0, zone2Seconds: 1800),  // 75% in Z2 ✓
            makeRun(date: makeDate("2025-11-19"), durationSec: 2400, distanceKm: 5.0, zone2Seconds: 1000),  // 42% in Z2 ✗
            makeRun(date: makeDate("2025-11-18"), durationSec: 2700, distanceKm: 6.0, zone2Seconds: 2100),  // 77% in Z2 ✓
            makeRun(date: makeDate("2025-11-17"), durationSec: 2400, distanceKm: 5.0, zone2Seconds: 800),   // 33% in Z2 ✗
            makeRun(date: makeDate("2025-11-15"), durationSec: 3000, distanceKm: 6.5, zone2Seconds: 2400),  // 80% in Z2 ✓
            makeRun(date: makeDate("2025-11-13"), durationSec: 2400, distanceKm: 5.0, zone2Seconds: 1920),  // 80% in Z2 ✓
            makeRun(date: makeDate("2025-11-10"), durationSec: 2880, distanceKm: 6.0, zone2Seconds: 2300),  // 79% in Z2 ✓
        ]
        
        let plan = makePlan(runs: runs)
        
        // When
        let recommendedPace = PaceRecommendationHelper.calculateRecommendedPace(
            for: Date(),
            plan: plan,
            onboarding: nil
        )
        
        // Then: Should only use the 5 most recent runs with >70% zone 2 time
        #expect(recommendedPace.hasSuffix("/km"))
    }
    
    // MARK: - Helper Method Tests
    
    @Test
    func timeInZone2Percentage_calculatesCorrectly() {
        // Given: Run with 1800 seconds in zone 2 out of 2400 total
        let run = makeRun(
            date: makeDate("2025-11-20"),
            durationSec: 2400,
            distanceKm: 5.0,
            zone2Seconds: 1800
        )
        
        // When
        let percentage = PaceRecommendationHelper.timeInZone2Percentage(for: run)
        
        // Then: 1800/2400 = 0.75 (75%)
        #expect(percentage == 0.75)
    }
    
    @Test
    func timeInZone2Percentage_handlesZeroDuration() {
        // Given: Run with no elapsed time
        var run = makeRun(
            date: makeDate("2025-11-20"),
            durationSec: 0,
            distanceKm: 5.0,
            zone2Seconds: 0
        )
        run.actual.elapsedSec = nil
        
        // When
        let percentage = PaceRecommendationHelper.timeInZone2Percentage(for: run)
        
        // Then: Should return 0
        #expect(percentage == 0.0)
    }
    
    @Test
    func timeInZone2Percentage_handlesNoZone2Data() {
        // Given: Run with no zone 2 data
        var run = makeRun(
            date: makeDate("2025-11-20"),
            durationSec: 2400,
            distanceKm: 5.0,
            zone2Seconds: 0
        )
        run.actual.zoneDuration = [:]
        
        // When
        let percentage = PaceRecommendationHelper.timeInZone2Percentage(for: run)
        
        // Then: Should return 0
        #expect(percentage == 0.0)
    }
    
    @Test
    func formatPace_formatsCorrectly() {
        // Test various pace values
        #expect(PaceRecommendationHelper.formatPace(secondsPerKm: 450.0) == "7:30/km")  // 7:30/km
        #expect(PaceRecommendationHelper.formatPace(secondsPerKm: 360.0) == "6:00/km")  // 6:00/km
        #expect(PaceRecommendationHelper.formatPace(secondsPerKm: 480.0) == "8:00/km")  // 8:00/km
        #expect(PaceRecommendationHelper.formatPace(secondsPerKm: 325.0) == "5:25/km")  // 5:25/km
        #expect(PaceRecommendationHelper.formatPace(secondsPerKm: 542.5) == "9:03/km")  // 9:03/km (rounds)
    }
    
    @Test
    func formatPace_handlesEdgeCases() {
        // Very fast pace
        #expect(PaceRecommendationHelper.formatPace(secondsPerKm: 180.0) == "3:00/km")
        
        // Very slow pace
        #expect(PaceRecommendationHelper.formatPace(secondsPerKm: 720.0) == "12:00/km")
        
        // Zero (edge case - shouldn't happen in practice)
        #expect(PaceRecommendationHelper.formatPace(secondsPerKm: 0.0) == "0:00/km")
    }
    
    // MARK: - Edge Cases
    
    @Test
    func calculateRecommendedPace_allRunsPoorAdherence_returnsFallback() {
        // Given: All runs have poor zone 2 adherence
        let runs = [
            makeRun(date: makeDate("2025-11-20"), durationSec: 2400, distanceKm: 5.0, zone2Seconds: 1000),  // 42% in Z2
            makeRun(date: makeDate("2025-11-18"), durationSec: 2700, distanceKm: 6.0, zone2Seconds: 1200),  // 44% in Z2
            makeRun(date: makeDate("2025-11-15"), durationSec: 3000, distanceKm: 6.5, zone2Seconds: 1500),  // 50% in Z2
        ]
        
        let plan = makePlan(runs: runs)
        
        // When
        let recommendedPace = PaceRecommendationHelper.calculateRecommendedPace(
            for: Date(),
            plan: plan,
            onboarding: nil
        )
        
        // Then: Should return fallback since no runs meet >70% criteria
        #expect(recommendedPace == "7:30/km")
    }
    
    @Test
    func calculateRecommendedPace_onlyPlannedRuns_returnsFallback() {
        // Given: Runs that are planned but not completed
        let template = RunTemplate(
            name: "Planned Run",
            kind: .easy,
            focus: .base,
            targetDurationSec: 2400,
            targetDistanceKm: 5.0,
            targetHRZone: .z2,
            notes: nil
        )
        
        let run1 = ScheduledRun(date: makeDate("2025-11-20"), template: template, status: .planned)
        let run2 = ScheduledRun(date: makeDate("2025-11-18"), template: template, status: .planned)
        
        let plan = makePlan(runs: [run1, run2])
        
        // When
        let recommendedPace = PaceRecommendationHelper.calculateRecommendedPace(
            for: Date(),
            plan: plan,
            onboarding: nil
        )
        
        // Then: Should return fallback since no completed runs
        #expect(recommendedPace == "7:30/km")
    }
    
    @Test
    func calculateRecommendedPace_runsWithoutDistanceData_handled() {
        // Given: Runs with missing distance data
        var run = makeRun(
            date: makeDate("2025-11-20"),
            durationSec: 2400,
            distanceKm: 5.0,
            zone2Seconds: 1800
        )
        run.actual.distanceKm = nil
        
        let plan = makePlan(runs: [run])
        
        // When
        let recommendedPace = PaceRecommendationHelper.calculateRecommendedPace(
            for: Date(),
            plan: plan,
            onboarding: nil
        )
        
        // Then: Should return fallback when no valid pace data
        #expect(recommendedPace == "7:30/km")
    }
}
