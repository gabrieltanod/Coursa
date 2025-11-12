//
//  EmptyState.swift
//  Coursa
//
//  Created by Gabriel Tanod on 08/11/25.
//

import SwiftUI

struct EmptyState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9), Color.gray.opacity(0.7),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(.top, 32)

            Text("Rest Day")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color("white-500"))

            Text(
                "Rest days are where the real gains happen. Don't skip your day off!"
            )
            .font(.system(size: 15))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color("white-500").opacity(0.7))
            .padding(.horizontal, 24)
            .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.top, 8)
    }
}

#Preview {
    EmptyState()
}
