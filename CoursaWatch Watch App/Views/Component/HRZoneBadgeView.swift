//
//  ZoneBarView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 28/10/25.
//

import SwiftUI

struct HRZoneBadgeView: View {
    let zoneNumber: Int

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
            Text("\(zoneNumber)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("app"))
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background(Color("secondary"))
        .cornerRadius(8)
    }
}
