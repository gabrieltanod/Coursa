//
//  PlanViewModel.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

import Combine
import Foundation

@MainActor
final class PlanViewModel: ObservableObject {
    @Published var data = OnboardingData()
    @Published var recommendedPlan: Plan?
    @Published var generatedPlan: GeneratedPlan?

    var plannedRuns: [ScheduledRun] {
        generatedPlan?.runs.filter {
            $0.status == .planned || $0.status == .inProgress
        } ?? []
    }

    var activityRuns: [ScheduledRun] {
        generatedPlan?.runs.filter {
            $0.status == .completed || $0.status == .skipped
        } ?? []
    }

    private var cancellables = Set<AnyCancellable>()
    
    init(data: OnboardingData) {
        self.data = data
        // Listen for plan updates
        NotificationCenter.default.publisher(for: NSNotification.Name("PlanUpdated"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.ensurePlanUpToDate()
            }
            .store(in: &cancellables)
    }

    var debugThisWeekMinutes: Int {
        let store = UserDefaultsPlanStore.shared
        let plan = store.load() ?? generatedPlan
        guard let plan else { return 0 }

        let start = Date().mondayFloor()
        return sumMinutes(runs: runs(in: plan, weekStart: start))
    }

    var debugNextWeekMinutes: Int {
        let store = UserDefaultsPlanStore.shared
        let plan = store.load() ?? generatedPlan
        guard let plan else { return 0 }

        let start = Date().mondayFloor().addingWeeks(1)
        return sumMinutes(runs: runs(in: plan, weekStart: start))
    }

    // Helpers (same logic as your tests)
    private func runs(in plan: GeneratedPlan, weekStart: Date) -> [ScheduledRun]
    {
        let weekEnd = weekStart.addingTimeInterval(7 * 24 * 60 * 60)
        return plan.runs.filter { $0.date >= weekStart && $0.date < weekEnd }
    }

    private func sumMinutes(runs: [ScheduledRun]) -> Int {
        runs.reduce(0) { acc, run in
            let sec =
                run.actual.elapsedSec ?? run.template.targetDurationSec ?? 0
            return acc + Int((Double(sec) / 60.0).rounded())
        }
    }

    #if DEBUG
        func debugCompleteThisWeekAndAdapt() {
            let store = UserDefaultsPlanStore.shared
            guard var plan = store.load() ?? generatedPlan else { return }

            let cal = Calendar.current

            // 1. Find the earliest week in the plan that still has active runs
            //    (planned or in-progress). This lets us reuse the debug button
            //    for later weeks, not just the first calendar week.
            let allWeekStarts = Set(plan.runs.map { $0.date.mondayFloor() })
            let sortedWeekStarts = allWeekStarts.sorted()

            guard
                let thisWeekStart = sortedWeekStarts.first(where: { weekStart in
                    let weekRuns = runs(in: plan, weekStart: weekStart)
                    return weekRuns.contains { run in
                        run.status == .planned || run.status == .inProgress
                    }
                })
            else {
                // No active weeks left to simulate.
                return
            }

            let thisWeekEnd = thisWeekStart.addingTimeInterval(7 * 24 * 60 * 60)
            #if DEBUG
                print(
                    "[DEBUG] before – completed: \(plan.runs.filter { $0.status == .completed }.count)"
                )
            #endif
            // 2. Mark all runs in this week as completed with mid-Z2 HR
            for idx in plan.runs.indices {
                let d = plan.runs[idx].date
                if d >= thisWeekStart && d < thisWeekEnd {
                    plan.runs[idx].status = .completed
                    let targetSec =
                        plan.runs[idx].template.targetDurationSec ?? 30 * 60
                    plan.runs[idx].actual.elapsedSec = targetSec
                    plan.runs[idx].actual.avgHR = 130
                }
            }
            
            let store = StoreManager.shared.currentPlanStore
            #if DEBUG
                print(
                    "[DEBUG] after – completed: \(plan.runs.filter { $0.status == .completed }.count)"
                )
            #endif
            store.save(plan)
            generatedPlan = plan

            // 3. Now simulate "now" at the start of the *next* week and run adaptation.
            let nextWeekStart = thisWeekStart.addingWeeks(1)

            let explicitDays = data.trainingPrefs.selectedDays
            let inferredDays = inferSelectedDays(from: plan)
            let selectedDays =
                explicitDays.isEmpty ? inferredDays : explicitDays

            let adapted = PlanMapper.applyWeeklyAdaptationIfDue(
                existing: plan,
                selectedDays: selectedDays,
                now: nextWeekStart
            )

            store.save(adapted)
            generatedPlan = adapted
        }
    #endif

    func computeRecommendation() {
        recommendedPlan = PlanLibrary.recommend(for: data)
        data.recommendedPlan = recommendedPlan
    }

    func generatePlan() {
        guard let generated = PlanMapper.generatePlan(from: data) else {
            return
        }
        generatedPlan = generated
        StoreManager.shared.currentPlanStore.save(generated)

        #if DEBUG
            PlanEngineDebug.printInitialPlan(from: data)
        #endif
    }

    func ensurePlanUpToDate(now: Date = Date()) {
        let store = StoreManager.shared.currentPlanStore

        // If there is no stored plan yet, fall back to initial generation.
        if store.load() == nil {
            generatePlan()
            return
        }

        // Load the latest stored plan and run it through the adaptation pipeline.
        guard let existing = store.load() else { return }

        // Prefer onboarding training prefs if available, otherwise infer from the plan.
        let explicitDays = data.trainingPrefs.selectedDays
        let inferredDays = inferSelectedDays(from: existing)
        let selectedDays = explicitDays.isEmpty ? inferredDays : explicitDays

        let adapted = PlanMapper.applyWeeklyAdaptationIfDue(
            existing: existing,
            selectedDays: selectedDays,
            now: now
        )

        store.save(adapted)
        generatedPlan = adapted
    }

    private func inferSelectedDays(from plan: GeneratedPlan) -> Set<Int> {
        let cal = Calendar.current
        let sample = plan.runs.prefix(14)
        return Set(sample.map { cal.component(.weekday, from: $0.date) })
    }

    func markRun(_ run: ScheduledRun, as newStatus: RunStatus) {
        guard newStatus == .completed || newStatus == .skipped,
            var plan = generatedPlan,
            let index = plan.runs.firstIndex(where: { $0.id == run.id })
        else {
            return
        }

        if plan.runs[index].status == newStatus { return }

        plan.runs[index].status = newStatus
        generatedPlan = plan
    }

    func markRunCompleted(_ run: ScheduledRun) {
        markRun(run, as: .completed)
    }

    func markRunSkipped(_ run: ScheduledRun) {
        markRun(run, as: .skipped)
    }

    func applyAutoSkipIfNeeded(now: Date = Date()) {
        guard var plan = generatedPlan else { return }
        let cal = Calendar.current
        let today = cal.startOfDay(for: now)
        var changed = false

        for i in plan.runs.indices {
            let runDay = cal.startOfDay(for: plan.runs[i].date)
            if runDay < today, plan.runs[i].status == .planned {
                plan.runs[i].status = .skipped
                changed = true
            }
        }

        if changed {
            generatedPlan = plan
        }
    }
    
    func updateRunWithSummary(_ summary: RunningSummary, forDate date: Date) {
        guard var plan = generatedPlan else { return }
        let calendar = Calendar.current
        
        // Find the run for today's date
        guard let runIndex = plan.runs.firstIndex(where: { run in
            calendar.isDate(run.date, inSameDayAs: date)
        }) else {
            print("⚠️ No run found for date: \(date)")
            return
        }
        
        // Update the run's actual metrics from summary
        plan.runs[runIndex].actual.elapsedSec = Int(summary.totalTime)
        plan.runs[runIndex].actual.distanceKm = summary.totalDistance
        plan.runs[runIndex].actual.avgHR = Int(summary.averageHeartRate)
        plan.runs[runIndex].actual.avgPaceSecPerKm = Int(summary.averagePace * 60) // Convert minutes to seconds
        
        // Mark as completed
        plan.runs[runIndex].status = .completed
        
        // Save the updated plan
        StoreManager.shared.currentPlanStore.save(plan)
        generatedPlan = plan
        
        print("✅ Updated run for \(date) with summary data and marked as completed")
    }
}

extension Date {
    fileprivate func mondayFloor() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2  // Monday
        let weekday = cal.component(.weekday, from: self)
        let delta = (weekday == 1) ? -6 : (2 - weekday)  // shift Sunday back 6, otherwise to Monday
        let start = cal.date(byAdding: .day, value: delta, to: self)!
        return cal.startOfDay(for: start)
    }
    fileprivate func addingDays(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: self)!
    }
    fileprivate func addingWeeks(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: 7 * n, to: self)!
    }
}
