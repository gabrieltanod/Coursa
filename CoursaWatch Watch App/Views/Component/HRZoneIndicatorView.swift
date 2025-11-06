//
//  ZoneBarView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 28/10/25.
//

import SwiftUI

struct HRZoneIndicatorView: View {
    let zoneNumber: Int
    let isActive: Bool

    private var backgroundColor: Color {
        if isActive {
            return Color("secondary")
        } else {
            switch zoneNumber {
            case 1...3: return Color("accent")
            case 4...5: return Color("accentSecondary")
            default: return Color.gray
            }
        }
    }
    
    private var zoneText: String {
        return isActive ? "Zone \(zoneNumber)" : "\(zoneNumber)"
    }

    var body: some View {
        Text(zoneText)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Color("app"))
            .padding(.horizontal, isActive ? 4 : 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(8)
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}
