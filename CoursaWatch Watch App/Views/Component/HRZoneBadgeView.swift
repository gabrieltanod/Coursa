//
//  ZoneBarView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 28/10/25.
//

import SwiftUI

struct HRZoneBadgeView: View {
    let zoneNumber: Int
    let isActive: Bool

    // Determine color based on zone and active state
//    private var backgroundColor: Color {
//        if isActive {
//            // Active zone is always yellow/neon
//            return Color("secondary") // Your Neon Yellow asset
//        } else {
//            // Inactive zones follow the standard color rule
//            switch zoneNumber {
//            case 1...3: return Color("accent") // Your Purple asset
//            case 4...5: return Color("accentSecondary") // Your Orange asset
//            default: return Color.gray
//            }
//        }
//    }

    // Determine text color based on background
    private var foregroundColor: Color {
        // If active (yellow background), use black text, otherwise white
        return isActive ? Color("app") : Color("app")
    }

    // Determine the text to display
    private var zoneText: String {
        return isActive ? "Zone \(zoneNumber)" : "\(zoneNumber)"
    }

    var body: some View {
        Text(zoneText)
            .font(.system(size: isActive ? 16 : 16, weight: .medium)) // Slightly smaller font when text is longer
            .foregroundColor(foregroundColor)
            // Apply more horizontal padding if active to make it wider
            .padding(.horizontal, isActive ? 4 : 8)
            .padding(.vertical, 4)
            .background(Color("secondary"))
            .cornerRadius(8) // Consistent corner radius
            // Add animation specifically for frame changes
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}
