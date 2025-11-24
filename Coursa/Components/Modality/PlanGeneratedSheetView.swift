//
//  PlanGeneratedSheetView.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 24/11/25.
//


import SwiftUI

struct PlanGeneratedSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isAnimated = false
    @EnvironmentObject private var planSession: PlanSessionStore
    private let calendar = Calendar.current
    let onboardingData = OnboardingStore.load()
    
    var body: some View {
        VStack (spacing: 16){
            Text("Finalize Plan")
                .font(.custom("Helvetica Neue", size: 20))
                .foregroundColor(Color.white)
                .padding(16)
            
            Image("CoursaImages/AdjustPlanSheet")
                .resizable()
                .scaledToFit()
                .clipped()
                .overlay(
                    ZStack {
                        LinearGradient(
                            colors: [.clear, Color("black-500")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
            
            VStack(alignment: .leading, spacing: 20){
                Text("Endurance Training Plan")
                    .font(.custom("Helvetica Neue", size: 28))
                    .foregroundColor(Color.white)
                    .bold()
                
                VStack(alignment: .leading, spacing: 8){
                    TextIconView(icon: "WeeksIcon", text: "\(calendarWeeks.count) Weeks")
                    TextIconView(icon: "Calendar", text: onboardingData?.startDate.formattedPlanDate() ?? "Date not set")
                }
                
                VStack(alignment: .leading, spacing: 16){
                    Text("Your plan is personalized based on these details:")
                        .font(.custom("Helvetica Neue", size: 16))
                    
                    if let dist = onboardingData?.personalBest.distanceKm, dist > 0,
                       let seconds = onboardingData?.personalBest.durationSeconds {
                        
                        TextIconView(
                            icon: "CheckIcon",
                            text: "Your current running record in \(dist.cleanAmount())km is \(seconds.formattedDuration())"
                        )
                    }
                    TextIconView(
                        icon: "CheckIcon",
                        text: "You are available to run on \(onboardingData?.trainingPrefs.selectedDays.formattedDays() ?? "No days selected")"
                    )
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.custom("Helvetica Neue", size: 17))
                        .foregroundColor(Color.black)
                        .frame(maxWidth: .infinity, minHeight: 54, alignment: .center)
                }
                .frame(maxWidth: .infinity, minHeight: 54, alignment: .center)
                .background(Color.white)
                .cornerRadius(20)
                .padding(.bottom, 40)
                .offset(y: isAnimated ? 0 : 50)
                .opacity(isAnimated ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimated)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
        }
        .background(Color("black-500"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            isAnimated = true
        }
    }
    
    
    private var calendarWeeks: [[Date]] {
        let runs = planSession.allRuns.sorted { $0.date < $1.date }

        guard let firstRunDate = runs.first?.date,
            let lastRunDate = runs.last?.date
        else {
            return []
        }

        // Compute week boundaries and force them to start on Monday
        guard
            let rawStart = calendar.dateInterval(
                of: .weekOfYear,
                for: firstRunDate
            )?.start,
            let rawEnd = calendar.dateInterval(
                of: .weekOfYear,
                for: lastRunDate
            )?.start
        else {
            return []
        }

        // Shift both to Monday
        let startOfFirstWeek =
            calendar.nextDate(
                after: rawStart,
                matching: DateComponents(weekday: 2),
                matchingPolicy: .nextTimePreservingSmallerComponents
            ) ?? rawStart
        let startOfLastWeek =
            calendar.nextDate(
                after: rawEnd,
                matching: DateComponents(weekday: 2),
                matchingPolicy: .nextTimePreservingSmallerComponents
            ) ?? rawEnd

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
    
}

extension Set<Int> {
    func formattedDays() -> String {
        let formatter = DateFormatter()
        
        let symbols = formatter.shortWeekdaySymbols ?? []
        
        let sortedDays = self.sorted()
        
        let dayStrings = sortedDays.map { dayInt -> String in
            let index = dayInt - 1
            if index >= 0 && index < symbols.count {
                return symbols[index]
            }
            return ""
        }
        
        let validDays = dayStrings.filter { !$0.isEmpty }
        
        switch validDays.count {
        case 0:
            return ""
        case 1:
            return validDays[0]
        case 2:
            return validDays.joined(separator: " and ")
        default:
            let allButLast = validDays.dropLast().joined(separator: ", ")
            let last = validDays.last!
            return "\(allButLast), and \(last)"
        }
    }
}

extension Date {
    func formattedPlanDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy"
        return formatter.string(from: self)
    }
}

extension Int {
    func formattedDuration() -> String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

extension Double {
    func cleanAmount() -> String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

#Preview {
    PlanGeneratedSheetView()
}
