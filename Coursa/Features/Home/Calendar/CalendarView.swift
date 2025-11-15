//
//  CalendarView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 08/11/25.
//

import SwiftUI

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = CalendarViewModel()
    private let calendar = Calendar.current

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        ZStack {
            Color("black-500").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                topBar

                monthSelector

                calendarCard

                Text("Session")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color("white-500"))
                    .padding(.top, 4)

                sessionList

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 40, height: 40)
                        .maybeGlassEffect()
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color("white-500"))
                }
            }
            Spacer()
            Text("Calendar")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color("white-500"))
            Spacer()
            // spacer to balance
            Color.clear.frame(width: 40, height: 40)
        }
    }

    // MARK: - Month Selector

    private var monthSelector: some View {
        HStack {
            Button {
                vm.changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(Color("white-500"))
            
            Spacer()
            
            Text(vm.monthTitle())
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color("white-500"))

            Spacer()

            Button {
                vm.changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(Color("white-500"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("black-450"))
                .maybeGlassEffect()
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
//                .maybeGlassEffect()
        )
    }

    // MARK: - Calendar Card

    private var calendarCard: some View {
        VStack(spacing: 10) {
            // Weekday row
            HStack {
                ForEach(["MON","TUE","WED","THU","FRI","SAT","SUN"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color("white-500").opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)

            // Dates grid
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Array(vm.monthGrid.enumerated()), id: \.offset) { _, maybeDate in
                    if let date = maybeDate {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 32)
                    }
                }
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color("black-450"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: vm.selectedDate)
        let hasRun = vm.hasRun(on: date)

        return VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(
                    isSelected ? Color.black : Color("white-500")
                )
                .frame(width: 32, height: 32)
                .background(
                    Group {
                        if isSelected {
                            Circle().fill(Color.white)
                        } else {
                            Color.clear
                        }
                    }
                )

            // Dot if there is a session (color based on run kind)
            if let run = vm.runs.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                let kind = run.template.kind
                let colorName: String = {
                    switch kind {
                    case .long:
                        return "long"   // asset for Long Run
                    case .easy:
                        return "easy"   // asset for Easy Run
                    default:
                        return "maf"    // asset for MAF / other runs
                    }
                }()

                Circle()
                    .fill(Color(colorName))
                    .frame(width: 6, height: 6)
                    .offset(y: 2)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
                    .offset(y: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            vm.selectedDate = date
        }
    }

    // MARK: - Sessions

    private var sessionList: some View {
        let sessions = vm.sessions(on: vm.selectedDate)

        return Group {
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

#Preview {
    CalendarView()
}
