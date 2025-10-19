//
//  WorkoutCardView.swift
//  Fico
//
//  Created by Gabriel Tanod on 13/10/25.
//

import SwiftUI

// MARK: - WorkoutCardView

struct WorkoutCardView: View {
    let workout: Workout
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(dateFormatter.string(from: workout.date)), \(workout.durationMin) min")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Text(workout.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text("\(workout.type) | \(String(format: "%.0fkm", workout.distanceKm))")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Workout: \(workout.title), \(workout.type), \(String(format: "%.0fkm", workout.distanceKm)), \(workout.durationMin) minutes")
    }
}

// MARK: - Preview

#Preview {
    WorkoutCardView(workout: Workout(
        date: Date(),
        durationMin: 30,
        title: "5k Lorem Ipsum",
        type: "Lorem Run",
        distanceKm: 5.0
    ))
    .padding()
}
