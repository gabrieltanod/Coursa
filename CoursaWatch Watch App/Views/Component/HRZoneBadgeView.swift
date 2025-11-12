//
//  ZoneBarView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 28/10/25.
//

import SwiftUI


struct HRZoneBadgeView: View {
    let zoneNumber: Int
    let bgColor: String
    let textColor: String
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
            Text("Zone \(zoneNumber)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(textColor))
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background(Color(bgColor))
        .cornerRadius(8)
    }
}
