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

    init(data: OnboardingData) {
        self.data = data
    }

    func computeRecommendation() {
        recommendedPlan = PlanLibrary.recommend(for: data)
        data.recommendedPlan = recommendedPlan
    }

    func generatePlan() {
        guard let generated = PlanMapper.generatePlan(from: data) else {
            return
        }
        generatedPlan = generated
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
}
