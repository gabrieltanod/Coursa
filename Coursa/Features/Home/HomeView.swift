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
        VStack(alignment: .leading, spacing: 4) {
            Text(greetingTitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color("white-500").opacity(0.8))

            Text("Today’s Training")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color("white-500"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greetingTitle: String {
        let hour = calendar.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<18: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    // MARK: - Calendar Strip (week-based)

    private var calendarStrip: some View {
        let weeks = calendarWeeks

        return TabView(selection: $selectedWeekIndex) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { index, days in
                HStack(spacing: 10) {
                    ForEach(days, id: \.self) { date in
                        let isSelected = calendar.isDate(date, inSameDayAs: vm.selectedDate)
                        let hasRun = vm.hasRun(on: date)

                        VStack(spacing: 6) {
                            Text(weekdayString(for: date).uppercased())
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(
                                    Color("white-500").opacity(isSelected ? 1.0 : 0.6)
                                )

                            Text(dayString(for: date))
                                .font(.system(size: 17, weight: .semibold))
                                .frame(width: 32, height: 32)
                                .foregroundStyle(isSelected ? .black : Color("white-500"))
                                .background(
                                    Circle()
                                        .fill(isSelected ? Color("white-500") : .clear)
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
              let lastRunDate = vm.runs.last?.date else {
            return []
        }

        let startComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: firstRunDate)
        let endComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastRunDate)

        guard let startOfFirstWeek = calendar.date(from: startComponents),
              let startOfLastWeek = calendar.date(from: endComponents) else {
            return []
        }

        var weeks: [[Date]] = []
        var currentWeekStart = startOfFirstWeek

        while currentWeekStart <= startOfLastWeek {
            var days: [Date] = []
            for offset in 0..<7 {
                if let d = calendar.date(byAdding: .day, value: offset, to: currentWeekStart) {
                    days.append(d)
                }
            }
            weeks.append(days)

            guard let next = calendar.date(byAdding: .day, value: 7, to: currentWeekStart) else {
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
                Text("No session scheduled")
                    .font(.system(size: 15))
                    .foregroundStyle(Color("white-500").opacity(0.6))
                    .padding(.top, 8)
            } else {
                Text(selectedDateTitle(vm.selectedDate))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color("white-500"))
                    .padding(.top, 4)

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

    private func selectedDateTitle(_ date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Today’s Session"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let f = DateFormatter()
            f.locale = Locale.current
            f.dateFormat = "EEEE, d MMM"
            return f.string(from: date)
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
