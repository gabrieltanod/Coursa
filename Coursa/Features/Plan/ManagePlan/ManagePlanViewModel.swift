//
//  ManagePlanViewModel.swift
//  Coursa
//
//  Created by Gabriel Tanod on 11/11/25.
//
//  Summary
//  -------
//  Glue between persistence, PlanMapper, and the Manage Plan UI.
//  Handles "schedule day" changes while preserving history.
//
//  Responsibilities
//  ----------------
//  - Load/save plan via PlanStore (UserDefaults for v1).
//  - Track user edits (goal, days).
//  - On save: regenerate future sessions only (preserve past).
//  - Never mutates completed/skipped sessions.
//

import Combine
import Foundation

final class ManagePlanViewModel: ObservableObject {
    @Published var selectedDays: Set<Int> = [] {
        didSet {
            // Any user change to selectedDays should mark the view model as dirty
            hasChanges = true
        }
    }
    @Published private(set) var hasChanges = false

    private let store: PlanStore
    private let today: Date

    init(
        store: PlanStore,
        today: Date = Date()
    ) {
        self.store = store
        self.today = today

        if let existing = store.load() {
            // Derive selectedDays from the weekdays used in the existing runs
            let cal = Calendar.current
            let days = Set(
                existing.runs.map { cal.component(.weekday, from: $0.date) }
            )
            self.selectedDays = days
            // Initial load should not be treated as a pending change
            self.hasChanges = false
        }
    }

    func saveChanges() {
        // If nothing has changed, skip any work
        guard hasChanges else { return }
        guard let oldPlan = store.load() else { return }

        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: today)

        // 1. Keep all runs strictly before today as-is (including their status)
        let pastRuns = oldPlan.runs.filter { $0.date < startOfToday }
        #if DEBUG
            print(
                "========== DEBUG: ManagePlanViewModel.saveChanges() =========="
            )

            print("[Before] Total runs: \(oldPlan.runs.count)")
            print("[Before] Past runs: \(pastRuns.count)")
            print(
                "[Before] Future runs: \(oldPlan.runs.count - pastRuns.count)"
            )

            print("[Selected Days] \(selectedDays.sorted())")

            print("-- Past Runs (Kept As-Is) --")
            for r in pastRuns {
                print(
                    "   • \(r.title) – \(r.date) – status: \(r.status.rawValue)"
                )
            }
        #endif
        // 2. Collect runs from today onward that need to be rescheduled
        var futureRuns = oldPlan.runs
            .filter { $0.date >= startOfToday }
            .sorted { $0.date < $1.date }

        // If there is no schedule set, just keep the existing plan
        guard !selectedDays.isEmpty else {
            store.save(oldPlan)
            hasChanges = false
            return
        }

        // 3. Reassign dates for future runs according to the new selectedDays
        let orderedDays = Array(selectedDays).sorted()  // weekday integers, e.g. 2 = Mon
        var reassignedRuns: [ScheduledRun] = []
        reassignedRuns.reserveCapacity(futureRuns.count)

        var currentDate = startOfToday
        var runIndex = 0

        // Helper to advance currentDate to the next calendar day
        func advanceOneDay() {
            if let next = cal.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = next
            }
        }

        // Walk forward in time until we have assigned all future runs
        while runIndex < futureRuns.count {
            let weekday = cal.component(.weekday, from: currentDate)

            if orderedDays.contains(weekday) {
                // Assign this date to the next run
                var run = futureRuns[runIndex]
                run.date = currentDate
                // We keep whatever status it had; typically these are planned runs
                reassignedRuns.append(run)
                runIndex += 1
            }

            advanceOneDay()
        }

        // 4. Merge past + future and ensure global ordering
        var newRuns: [ScheduledRun] = []
        newRuns.reserveCapacity(pastRuns.count + reassignedRuns.count)
        newRuns.append(contentsOf: pastRuns)
        newRuns.append(contentsOf: reassignedRuns)
        newRuns.sort { $0.date < $1.date }

        // 5. Build a new plan with updated runs
        let newPlan = GeneratedPlan(
            plan: oldPlan.plan,
            runs: newRuns
        )
        #if DEBUG
            print("-- Reassigned Future Runs --")
            for r in reassignedRuns {
                print("   • \(r.title) – NEW DATE: \(r.date)")
            }

            print("-- Final Sorted Runs --")
            for r in newRuns {
                print(
                    "   • \(r.title) – \(r.date) – status: \(r.status.rawValue)"
                )
            }

            print("[After] Total runs: \(newRuns.count)")
            print(
                "=============================================================="
            )
        #endif
        // 6. Persist and clear change flag
        store.save(newPlan)
        hasChanges = false
    }
}
