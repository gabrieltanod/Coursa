//
//  TopNavView.swift
//  Fico
//
//  Created by Gabriel Tanod on 13/10/25.
//

import SwiftUI

// MARK: - TopNavView

struct TopNavView: View {
    var body: some View {
        HStack {
            // Profile button
            Button(action: {}) {
                Text("MK")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: LayoutConstants.profileButtonSize, height: LayoutConstants.profileButtonSize)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Profile")
            .accessibilityHint("Tap to view profile")
            
            Spacer()
            
            // Title
            Text("Week 1/8")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Right icon
            Button(action: {}) {
                Image(systemName: "envelope")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
            }
            .accessibilityLabel("Messages")
            .accessibilityHint("Tap to view messages")
        }
        .padding(.horizontal, LayoutConstants.horizontalPadding)
    }
}

// MARK: - Preview

#Preview {
    TopNavView()
        .padding()
}
