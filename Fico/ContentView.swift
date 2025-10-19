//
//  ContentView.swift
//  Fico
//
//  Created by Gabriel Tanod on 13/10/25.
//

import SwiftUI

// MARK: - Main ContentView

struct ContentView: View {
    @State private var selectedDayIndex = 0
    
    private let mockDays: [DayItem] = [
        DayItem(weekdayShort: "MON", day: 1, isToday: true, isSelected: true),
        DayItem(weekdayShort: "TUE", day: 2, isToday: false, isSelected: false),
        DayItem(weekdayShort: "WED", day: 3, isToday: false, isSelected: false),
        DayItem(weekdayShort: "THU", day: 4, isToday: false, isSelected: false),
        DayItem(weekdayShort: "FRI", day: 5, isToday: false, isSelected: false),
        DayItem(weekdayShort: "SAT", day: 6, isToday: false, isSelected: false),
        DayItem(weekdayShort: "SUN", day: 7, isToday: false, isSelected: false)
    ]
    
    private let mockWorkout = Workout(
        date: Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date(),
        durationMin: 30,
        title: "5k Lorem Ipsum",
        type: "Lorem Run",
        distanceKm: 5.0
    )
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: LayoutConstants.verticalSpacing) {
                    // Top Navigation
                    TopNavView()
                        .padding(.top, 8)
                    
                    // Weekday Selector
                    WeekdaySelectorView(days: mockDays)
                    
                    // First Lorem Ipsum Section
                    VStack(alignment: .leading, spacing: LayoutConstants.verticalSpacing) {
                        HStack {
                            Text("Lorem Ipsum")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, LayoutConstants.horizontalPadding)
                        
                        // Workout Card
                        WorkoutCardView(workout: mockWorkout)
                            .padding(.horizontal, LayoutConstants.horizontalPadding)
                        
                        // Progress Card
                        ProgressCardView(
                            title: "Lorem Ipsum",
                            progress: 0.6,
                            caption: "Lorem ipsum : xx KM"
                        )
                        .padding(.horizontal, LayoutConstants.horizontalPadding)
                    }
                    
                    // Divider
                    Rectangle()
                        .fill(Color.primary)
                        .frame(height: 1)
                        .padding(.horizontal, LayoutConstants.horizontalPadding)
                    
                    // Second Lorem Ipsum Section
                    VStack(alignment: .leading, spacing: LayoutConstants.verticalSpacing) {
                        HStack {
                            Text("Lorem Ipsum")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, LayoutConstants.horizontalPadding)
                        
                        // Media Grid
                        MediaGridView()
                            .padding(.horizontal, LayoutConstants.horizontalPadding)
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}
