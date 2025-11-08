//
//  PlanView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

// PlanView.swift (update)
import SwiftUI

struct PlanView: View {
    @StateObject var vm: PlanViewModel

    // MARK: - Tab state and enum
    private enum PlanInnerTab: String, CaseIterable { case plan = "Plan"; case activity = "Activity" }
    @State private var selectedTab: PlanInnerTab = .plan
    @State private var selectedWeekIndex: Int? = nil

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                header()

                planTabs()

                if selectedTab == .plan {
                    if let generated = vm.generatedPlan {
                        // --- derive plan stats ---
                        let runs = generated.runs.sorted { $0.date < $1.date }                      // your `generated.runs.sorted { $0.date < $1.date }`
                        let totalSessions = generated.runs.count
                        let completedSessions = generated.runs.filter { $0.status == .completed }.count
                        let progress = totalSessions == 0 ? 0 : Double(completedSessions) / Double(totalSessions)

                        // distance completed (prefer actual.distanceKm, fallback to template targetDistanceKm)
                        let completedKm = runs
                            .filter { $0.status == .completed }
                            .reduce(0.0) { sum, run in
                                if let d = run.actual.distanceKm { return sum + d }
                                if let t = run.template.targetDistanceKm { return sum + t }
                                return sum
                            }

                        // target distance = sum of template targets (ignore nils)
                        let targetKm = runs
                            .compactMap { $0.template.targetDistanceKm }
                            .reduce(0, +)

                        // weeks
                        let allGroups = groupByWeek(runs)
                        let weekTotal = max(allGroups.count, 1)
                        let weekNow = (selectedWeekIndex ?? 0) + 1

                        let sorted = generated.runs.sorted { $0.date < $1.date }
                        let now = Date()
                        
                        // Determine default (current) week index
                        let defaultIndex =
                            allGroups.firstIndex { group in
                                guard let first = group._value.first?.date else { return false }
                                return first >= Calendar.current.startOfDay(for: now)
                            } ?? 0
                        
                        // Bind selected index, defaulting to current week
                        let bindingIndex = Binding<Int>(
                            get: { selectedWeekIndex ?? defaultIndex },
                            set: { selectedWeekIndex = max(0, min($0, max(allGroups.count - 1, 0))) }
                        )
                        let selectedIndex = bindingIndex.wrappedValue
                        
                        // Today runs (only if viewing current week)
                        let todayRuns = sorted.filter { Calendar.current.isDate($0.date, inSameDayAs: now) }
                        let selectedGroup = allGroups.isEmpty ? nil : allGroups[selectedIndex]
                        let selectedRuns = selectedGroup?._value ?? []
                        let selectedRunsExcludingToday = selectedRuns.filter { !Calendar.current.isDate($0.date, inSameDayAs: now) }
                        let upcomingGroups = Array(allGroups.dropFirst(min(selectedIndex + 1, allGroups.count)))
                        
                        ScrollView {
                            
                            LazyVStack(alignment: .leading, spacing: 20) {
                                PlanProgressCard(
                                    title: vm.recommendedPlan?.rawValue ?? "Base Endurance Plan",
                                    progress: progress,
                                    weekNow: weekNow,
                                    weekTotal: weekTotal,
                                    completedKm: completedKm,
                                    targetKm: targetKm
                                )
                                
                                weekSelector(totalWeeks: allGroups.count, currentIndex: bindingIndex)
                                    .padding(.bottom, 8)
                                // Show Today only when looking at the current week
                                if selectedIndex == defaultIndex, !todayRuns.isEmpty {
                                    Text("Today")
                                        .font(.system(size: 15, weight: .semibold))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 4)
                                        .foregroundStyle(Color("white-500"))
                                    
                                    ForEach(todayRuns) { run in
                                        NavigationLink {
                                            PlanDetailView(run: run)
                                        } label: {
                                            RunningSessionCard(run: run)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                
                                Text("Week \(selectedIndex + 1) Sessions")
                                    .font(.system(size: 15, weight: .semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 4)
                                    .foregroundStyle(Color("white-500"))
                                
                                ForEach(selectedRunsExcludingToday) { run in
                                    NavigationLink {
                                        PlanDetailView(run: run)
                                    } label: {
                                        RunningSessionCard(run: run)
                                    }
                                }
                                .padding(.vertical, -5)
                            }
                            .padding(.vertical)
                        }
                    } else {
                        Spacer()
                        Text("No plan yet")
                            .foregroundColor(.secondary)
                            .foregroundStyle(Color("white-500"))
                        Spacer()
                    }
                } else {
                    // Activity placeholder
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 36, weight: .regular))
                            .foregroundStyle(Color("white-500").opacity(0.8))
                        Text("Activity will live here")
                            .font(.headline)
                            .foregroundStyle(Color("white-500"))
                        Text("Your recent runs, stats, and trends will appear on this tab.")
                            .font(.subheadline)
                            .foregroundStyle(Color("white-500").opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 32)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
//            .navigationTitle("Your Plan").foregroundStyle(Color("white-500"))
            .onAppear {
                if vm.recommendedPlan == nil { vm.computeRecommendation() }
                if vm.generatedPlan == nil { vm.generatePlan() }
            }

        }
        .background(Color("black-500"))
    }
    // MARK: - Tab bar
    @ViewBuilder
    private func planTabs() -> some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(PlanInnerTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(size: 17, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundStyle(Color("white-500").opacity(selectedTab == tab ? 1.0 : 0.65))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // baseline + underline for selected tab
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color("white-500").opacity(0.15))
                    .frame(height: 1)

                HStack(spacing: 0) {
                    Rectangle()
                        .fill(selectedTab == .plan ? Color("white-500") : .clear)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Rectangle()
                        .fill(selectedTab == .activity ? Color("white-500") : .clear)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    @ViewBuilder
    private func weekSelector(totalWeeks: Int, currentIndex: Binding<Int>) -> some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    if currentIndex.wrappedValue > 0 {
                        currentIndex.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.white)
                        .frame(width: 32, height: 32)
                        
                }
                .buttonStyle(.plain)
                
                Text("Week \(currentIndex.wrappedValue + 1)")
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.white)
                
                Button {
                    if currentIndex.wrappedValue < totalWeeks - 1 {
                        currentIndex.wrappedValue += 1
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

    // MARK: - Small pieces

    @ViewBuilder
    private func header() -> some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Plan")
                    .font(.system(size: 35))
                    .foregroundStyle(Color("white-500"))
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
}

#Preview("PlanView – with OnboardingData") {
    var onboarding = OnboardingData()
    onboarding.goal = .improveEndurance
    onboarding.personalInfo = .init(age: 22, gender: "M", weightKg: 68, heightCm: 173)
    onboarding.trainingPrefs = .init(daysPerWeek: 4, selectedDays: [2, 4, 6, 7]) // Mon, Wed, Fri, Sat
    onboarding.personalBest = .init(distanceKm: 5.0, durationSeconds: 25 * 60)   // 25:00 for 5K
    onboarding.startDate = Calendar.current.nextDate(
        after: Date(),
        matching: DateComponents(weekday: 2), // next Monday
        matchingPolicy: .nextTime
    ) ?? Date()

    return NavigationStack {
        PlanView(vm: PlanViewModel(data: onboarding))
//            .preferredColorScheme(.dark)
            .background(Color("black-500"))
    }
}
