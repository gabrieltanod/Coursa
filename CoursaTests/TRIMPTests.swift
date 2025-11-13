//
//  TRIMPTests.swift
//  Coursa
//
//  Created by Gabriel Tanod on 13/11/25.
//
//  AdaptationEngineTests.swift
//  CoursaTests
//
//  Uses Swift Testing (no XCTest).
//

import Testing
@testable import Coursa   // change to your app module name

struct TRIMPTests {

    @Test
    func trimpIsZeroWhenNoDuration() {
        let value = TRIMP.sessionTRIMP(
            durationSec: 0,
            avgHR: 140,
            maxHR: 200,
            gender: .male
        )

        #expect(value == 0)
    }

    @Test
    func trimpIncreasesWithDuration() {
        let short = TRIMP.sessionTRIMP(
            durationSec: 30 * 60,    // 30 min
            avgHR: 140,
            maxHR: 200,
            gender: .male
        )
        let long = TRIMP.sessionTRIMP(
            durationSec: 60 * 60,    // 60 min
            avgHR: 140,
            maxHR: 200,
            gender: .male
        )

        #expect(long > short)
    }

    @Test
    func trimpIncreasesWithIntensity() {
        let low = TRIMP.sessionTRIMP(
            durationSec: 45 * 60,
            avgHR: 130,
            maxHR: 200,
            gender: .male
        )
        let high = TRIMP.sessionTRIMP(
            durationSec: 45 * 60,
            avgHR: 170,
            maxHR: 200,
            gender: .male
        )

        #expect(high > low)
    }
}

struct AdaptationEngineTests {

    // Helper to keep numbers readable
    private func nextWeekMinutes(
        lastWeekTRIMP: Double,
        thisWeekTRIMP: Double,
        lastWeekMinutes: Int,
        runningFrequency: Int = 3
    ) -> Int {
        AdaptationEngine.nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes,
            runningFrequency: runningFrequency
        )
    }

    @Test
    func undertrainedRepeatsWeek() {
        // PRD: WeeklyTRIMP < lastWeekTRIMP * 0.9 → overloadFactor = 1.0 (repeat week)
        let lastWeekTRIMP = 100.0
        let thisWeekTRIMP = 80.0    // 0.8 * lastWeekTRIMP
        let lastWeekMinutes = 150

        let next = nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes
        )

        #expect(next == lastWeekMinutes)
    }

    @Test
    func overreachedRepeatsWeek() {
        // PRD: WeeklyTRIMP > lastWeekTRIMP * 1.2 → overloadFactor = 1.0 (repeat week)
        let lastWeekTRIMP = 100.0
        let thisWeekTRIMP = 130.0   // 1.3 * lastWeekTRIMP
        let lastWeekMinutes = 150

        let next = nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes
        )

        #expect(next == lastWeekMinutes)
    }

    @Test
    func goodProgressIncreasesByAboutFivePercent() {
        // PRD: WeeklyTRIMP in [1.0, 1.1] * lastWeekTRIMP → overloadFactor = 1.05
        let lastWeekTRIMP = 100.0
        let thisWeekTRIMP = 105.0   // inside [1.0, 1.1] window
        let lastWeekMinutes = 150

        let next = nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes
        )

        // 150 * 1.05 = 157.5 → ~158
        #expect(next >= 157 && next <= 160)
    }

    @Test
    func growthIsCappedAtTenPercent() {
        // Even if math tried to push more, final value must be <= 110% of lastWeekMinutes
        let lastWeekTRIMP = 100.0
        let thisWeekTRIMP = 105.0
        let lastWeekMinutes = 200

        let next = nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes
        )

        let maxAllowed = Int((Double(lastWeekMinutes) * 1.10).rounded())
        #expect(next <= maxAllowed)
    }
}
