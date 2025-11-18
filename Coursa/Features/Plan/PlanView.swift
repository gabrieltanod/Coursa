//
//  PlanView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

// PlanView.swift (update)
import SwiftUI

struct PlanView: View {
    @ObservedObject var vm: PlanViewModel
    @EnvironmentObject private var planSession: PlanSessionStore

    // MARK: - Tab state and enum
    fileprivate enum PlanInnerTab: String, CaseIterable {
        case plan = "Plan"
        case activity = "History"
    }
    @State private var selectedTab: PlanInnerTab = .plan
    @State private var selectedWeekIndex: Int? = nil

    var body: some View {
//        #if DEBUG
//            VStack(alignment: .leading, spacing: 4) {
//                Text("DEBUG – This week: \(vm.debugThisWeekMinutes) min")
//                Text("DEBUG – Next week: \(vm.debugNextWeekMinutes) min")
//                Button("Fake Complete First Run") {
//                    if let run = (planSession.generatedPlan ?? UserDefaultsPlanStore.shared.load())?.runs.first {
//                        let fake = RunningSummary(
//                            id: run.id,
//                            totalTime: 1800,
//                            totalDistance: 5.0,
//                            averageHeartRate: 140,
//                            averagePace: 360
//                        )
//                        planSession.apply(summary: fake)
//                    }
//                }
//                Button("DEBUG – Log all run IDs") {
//                        if let plan = planSession.generatedPlan {
//                            print("===== DEBUG: ScheduledRun IDs in generatedPlan =====")
//                            for run in plan.runs {
//                                print("[DEBUG] id=\(run.id), title=\(run.title), date=\(run.date)")
//                            }
//                            print("====================================================")
//                        } else {
//                            print("[DEBUG] No generatedPlan loaded in PlanSessionStore")
//                        }
//                    }
//            }
//            .font(.caption)
//            .foregroundColor(.secondary)
//            .padding(.horizontal)
//            .padding(.top, 4)
//        #endif
//        #if DEBUG
////            Button("Fake Complete First Run") {
////                if let run = (planSession.generatedPlan ?? UserDefaultsPlanStore.shared.load())?.runs.first {
////                    let fake = RunningSummary(
////                        id: run.id,
////                        totalTime: 1800,
////                        totalDistance: 5.0,
////                        averageHeartRate: 140,
////                        averagePace: 360
////                    )
////                    planSession.applyWatchSummary(fake)
////                }
////            }
//        #endif
        ZStack {
            VStack(spacing: 16) {
                PlanHeader()

                PlanTabs(selectedTab: $selectedTab)

                if selectedTab == .plan {
                    PlanScheduleView()
                } else {
                    // Activity tab: completed & skipped runs
                    let activitySource =
                        planSession.generatedPlan
                        ?? UserDefaultsPlanStore.shared.load()

                    let activity = (activitySource?.runs ?? [])
                        .filter {
                            $0.status == .completed || $0.status == .skipped
                        }
                        .sorted { $0.date > $1.date }

                    if activity.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 36, weight: .regular))
                                .foregroundStyle(
                                    Color("white-500").opacity(0.8)
                                )
                            Text("No activity yet")
                                .font(.headline)
                                .foregroundStyle(Color("white-500"))
                            Text("Completed and skipped runs will appear here.")
                                .font(.subheadline)
                                .foregroundStyle(
                                    Color("white-500").opacity(0.7)
                                )
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .top
                        )
                        .padding(.top, 32)
                    } else {
                        let monthGroups = groupByMonth(activity)

                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 24) {
                                ForEach(monthGroups) { group in
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(monthYearTitle(for: group._key))
                                            .font(
                                                .system(
                                                    size: 15,
                                                    weight: .semibold
                                                )
                                            )
                                            .foregroundStyle(Color("white-500"))

                                        LazyVStack(
                                            alignment: .leading,
                                            spacing: 12
                                        ) {
                                            ForEach(group._value) { run in
                                                NavigationLink {
                                                    RunningSummaryView(run: run)
                                                } label: {
                                                    RunningHistoryCard(
                                                        run: run,
                                                        isSkipped: run.status
                                                            == .skipped
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            //            .navigationTitle("Your Plan").foregroundStyle(Color("white-500"))
            .onAppear {
                if vm.recommendedPlan == nil { vm.computeRecommendation() }
                vm.ensurePlanUpToDate()
                vm.applyAutoSkipIfNeeded()
                // After any adjustments, reload the shared plan from persistence
                planSession.generatedPlan = UserDefaultsPlanStore.shared.load()
            }
//                        #if DEBUG
//                            .toolbar {
//                                ToolbarItem(placement: .topBarTrailing) {
//                                    Button("Debug Adapt") {
//                                        vm.debugCompleteThisWeekAndAdapt()
//                                    }
//                                }
//                            }
//                            .navigationBarTitleDisplayMode(.inline)
//                        #endif
        }
        .background(Color("black-500"))
    }

    // group runs by [year, weekOfYear] so weeks don’t mix across years
    private struct WeekKey: Hashable, Comparable {
        let year: Int
        let week: Int
        static func < (l: WeekKey, r: WeekKey) -> Bool {
            (l.year, l.week) < (r.year, r.week)
        }
    }
    private struct WeekGroup: Identifiable {
        let id = UUID()
        let _key: WeekKey
        let _value: [ScheduledRun]
    }
    private func groupByWeek(_ runs: [ScheduledRun]) -> [WeekGroup] {
        let cal = Calendar.current
        let groups = Dictionary(grouping: runs) { run -> WeekKey in
            WeekKey(
                year: cal.component(.yearForWeekOfYear, from: run.date),
                week: cal.component(.weekOfYear, from: run.date)
            )
        }
        return groups.keys.sorted().map { key in
            WeekGroup(
                _key: key,
                _value: groups[key]!.sorted { $0.date < $1.date }
            )
        }
    }

    // MARK: - Month grouping for history

    private struct MonthKey: Hashable, Comparable {
        let year: Int
        let month: Int

        static func < (l: MonthKey, r: MonthKey) -> Bool {
            (l.year, l.month) < (r.year, r.month)
        }
    }

    private struct MonthGroup: Identifiable {
        let id = UUID()
        let _key: MonthKey
        let _value: [ScheduledRun]
    }

    private func groupByMonth(_ runs: [ScheduledRun]) -> [MonthGroup] {
        let cal = Calendar.current
        let groups = Dictionary(grouping: runs) { run -> MonthKey in
            let comps = cal.dateComponents([.year, .month], from: run.date)
            return MonthKey(
                year: comps.year ?? 0,
                month: comps.month ?? 1
            )
        }

        // Newest month first
        return groups.keys.sorted(by: >).map { key in
            MonthGroup(
                _key: key,
                _value: groups[key]!.sorted { $0.date > $1.date }
            )
        }
    }

    private func monthYearTitle(for key: MonthKey) -> String {
        var comps = DateComponents()
        comps.year = key.year
        comps.month = key.month

        let cal = Calendar.current
        let date = cal.date(from: comps) ?? Date()

        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

private struct PlanHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Plan")
                .font(.system(size: 34))
                .foregroundStyle(Color("white-500"))
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PlanTabs: View {
    @Binding var selectedTab: PlanView.PlanInnerTab

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(PlanView.PlanInnerTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Text(tab.rawValue)
                            .font(
                                .system(
                                    size: 17,
                                    weight: selectedTab == tab
                                        ? .semibold : .regular
                                )
                            )
                            .foregroundStyle(
                                Color("white-500").opacity(
                                    selectedTab == tab ? 1.0 : 0.65
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color("white-500").opacity(0.15))
                    .frame(height: 1)

                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            selectedTab == .plan ? Color("white-500") : .clear
                        )
                        .frame(height: 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Rectangle()
                        .fill(
                            selectedTab == .activity
                                ? Color("white-500") : .clear
                        )
                        .frame(height: 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

private struct WeekSelector: View {
    let totalWeeks: Int
    @Binding var currentIndex: Int

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    if currentIndex > 0 {
                        currentIndex -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.white)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Text("Week \(currentIndex + 1)")
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.white)

                Button {
                    if currentIndex < totalWeeks - 1 {
                        currentIndex += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 17, weight: .medium))
                        .frame(width: 32, height: 32)
                        .foregroundStyle(Color.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("black-450"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color("white-500").opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview("PlanView – with OnboardingData") {
    var onboarding = OnboardingData()
    onboarding.goal = .improveEndurance
    onboarding.personalInfo = .init(
        age: 22,
        gender: "M",
        weightKg: 68,
        heightCm: 173
    )
    onboarding.trainingPrefs = .init(
        daysPerWeek: 4,
        selectedDays: [2, 4, 6, 7]
    )  // Mon, Wed, Fri, Sat
    onboarding.personalBest = .init(distanceKm: 5.0, durationSeconds: 25 * 60)  // 25:00 for 5K
    onboarding.startDate =
        Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(weekday: 2),  // next Monday
            matchingPolicy: .nextTime
        ) ?? Date()

    return NavigationStack {
        PlanView(vm: PlanViewModel(data: onboarding))
            //            .preferredColorScheme(.dark)
            .background(Color("black-500"))
    }
}
