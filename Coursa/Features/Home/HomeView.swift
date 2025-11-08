//
//  HomeView.swift
//  Coursa
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var selectedWeekIndex: Int = 0
    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            Color("black-500").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                header

                calendarStrip

                sessionsSection

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }

    // MARK: - Header

    private var header: some View {
        let weekCount = calendarWeeks.count
        // Clamp index safely in case weeks are not yet loaded
        let safeIndex = weekCount > 0 ? min(max(selectedWeekIndex, 0), weekCount - 1) : 0

        return HStack(spacing: 12) {
            HStack(spacing: 2) {
                Text("Week \(weekCount == 0 ? 1 : safeIndex + 1)")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color("white-500"))
                
                VStack(spacing: 0) {
                    Text("")
                    if weekCount > 0 {
                        Text("/\(weekCount)")
                            .font(.system(size: 17, weight: .medium))
                            .baselineOffset(4)
                            .foregroundStyle(Color("white-500").opacity(0.9))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink {
                CalendarView()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 40, height: 40)
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color("white-500"))
                }
            }
            .buttonStyle(.plain)
        }
    }


    // MARK: - Calendar Strip (week-based)

    private var calendarStrip: some View {
        let weeks = calendarWeeks

        return TabView(selection: $selectedWeekIndex) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { index, days in
                HStack(spacing: 10) {
                    ForEach(days, id: \.self) { date in
                        let isSelected = calendar.isDate(
                            date,
                            inSameDayAs: vm.selectedDate
                        )
                        let hasRun = vm.hasRun(on: date)

                        VStack(spacing: 6) {
                            Text(weekdayString(for: date).uppercased())
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(
                                    Color("white-500").opacity(
                                        isSelected ? 1.0 : 0.6
                                    )
                                )

                            Text(dayString(for: date))
                                .font(.system(size: 17, weight: .semibold))
                                .frame(width: 32, height: 32)
                                .foregroundStyle(
                                    isSelected ? .black : Color("white-500")
                                )
                                .background(
                                    Circle()
                                        .fill(
                                            isSelected
                                                ? Color("white-500") : .clear
                                        )
                                )

                            Circle()
                                .fill(Color("purple-500"))
                                .frame(width: 6, height: 6)
                                .opacity(hasRun ? 1 : 0)
                                .offset(y: -2)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.selectedDate = date
                        }
                    }
                }
                .tag(index)
                .frame(maxWidth: .infinity)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 80)
    }

    // Weeks from first plan week to last plan week, each exactly 7 days.
    // No pre-plan weeks → no empty calendar before your plan.
    private var calendarWeeks: [[Date]] {
        guard let firstRunDate = vm.runs.first?.date,
            let lastRunDate = vm.runs.last?.date
        else {
            return []
        }

        let startComponents = calendar.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: firstRunDate
        )
        let endComponents = calendar.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: lastRunDate
        )

        guard let startOfFirstWeek = calendar.date(from: startComponents),
            let startOfLastWeek = calendar.date(from: endComponents)
        else {
            return []
        }

        var weeks: [[Date]] = []
        var currentWeekStart = startOfFirstWeek

        while currentWeekStart <= startOfLastWeek {
            var days: [Date] = []
            for offset in 0..<7 {
                if let d = calendar.date(
                    byAdding: .day,
                    value: offset,
                    to: currentWeekStart
                ) {
                    days.append(d)
                }
            }
            weeks.append(days)

            guard
                let next = calendar.date(
                    byAdding: .day,
                    value: 7,
                    to: currentWeekStart
                )
            else {
                break
            }
            currentWeekStart = next
        }

        return weeks
    }

    private func weekdayString(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    private func dayString(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "d"
        return f.string(from: date)
    }

    // MARK: - Sessions List

    private var sessionsSection: some View {
        let sessions = vm.sessions(on: vm.selectedDate)
        
        return VStack(alignment: .leading, spacing: 12) {
            if sessions.isEmpty {
                EmptyState()
            } else {
                ForEach(sessions) { run in
                    NavigationLink {
                        PlanDetailView(run: run)
                    } label: {
                        RunningSessionCard(run: run)
                    }
                }
            }
        }
    }
}

#Preview("HomeView") {
    NavigationStack {
        HomeView()
            .background(Color("black-500"))
            .preferredColorScheme(.dark)
    }
}
