//
//  Bugs.swift
//  Coursa
//
//  Created by Gabriel Tanod on 13/11/25.
//

//  PlanEngineDebug.swift
//  Coursa
//
//  Only used for manual debugging in DEBUG builds.

import Foundation

#if DEBUG

    enum PlanEngineDebug {

        static func printInitialPlan(from data: OnboardingData) {
            print("===== ENGINE DEBUG: Initial Plan =====")
            guard let plan = PlanMapper.generatePlan(from: data) else {
                print("Failed to generate plan from onboarding data")
                return
            }
            plan.debugPrint(label: "Initial")
        }

        static func printRegeneratedPlan(
            from existing: GeneratedPlan,
            newSelectedDays: Set<Int>,
            today: Date = Date()
        ) {
            print(
                "===== ENGINE DEBUG: Regenerated Plan (schedule change) ====="
            )
            let updated = PlanMapper.regeneratePlan(
                existing: existing,
                newPlan: nil,
                newSelectedDays: newSelectedDays,
                today: today
            )
            updated.debugPrint(label: "After schedule change")
        }
    }

    extension GeneratedPlan {
        func debugPrint(label: String) {
            print("---- \(label) plan ----")
            print("Plan type:", plan)
            print("Total runs:", runs.count)

            let cal = Calendar.current
            let grouped = Dictionary(grouping: runs) {
                (run: ScheduledRun) -> String in
                let comps = cal.dateComponents(
                    [.yearForWeekOfYear, .weekOfYear],
                    from: run.date
                )
                return
                    "Y\(comps.yearForWeekOfYear ?? 0)-W\(comps.weekOfYear ?? 0)"
            }

            for key in grouped.keys.sorted() {
                print("  Week \(key):")
                for run in grouped[key]!.sorted(by: { $0.date < $1.date }) {
                    let dayFormatter = DateFormatter()
                    dayFormatter.dateFormat = "EEE d MMM"
                    let dateString = dayFormatter.string(from: run.date)

                    let targetMin = (run.template.targetDurationSec ?? 0) / 60
                    let zone = run.template.targetHRZone?.rawValue ?? 0

                    print(
                        "    • \(dateString) | \(run.title) | \(targetMin) min | Z\(zone) | status: \(run.status)"
                    )
                }
            }

            print("---- end \(label) ----")
        }
    }

#endif
