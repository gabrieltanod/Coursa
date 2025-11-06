//
//  ButtonControlView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct PlanCardView: View {
    let date : Date
    let title: String
    let targetDistance: String
    let intensity: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(formatDate(date))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("\(targetDistance) - \(intensity)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.5))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yy"
        return formatter.string(from: date)
    }
}

#Preview {
    PlanCardView(date: Date(), title: "Easy Run", targetDistance: "3km", intensity: "HR Zone 2")
}
