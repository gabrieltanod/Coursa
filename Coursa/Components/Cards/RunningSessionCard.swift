//
//  RunningSessionCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 27/10/25.
//

import SwiftUI

struct RunningSessionCard: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardGradient)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: overlaySymbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundStyle(.white.opacity(0.15))
                        .padding(-10)
//                        .allowsHitTesting(false)
                }
                .clipped()

                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)

                        .strokeBorder(Color("black-400").opacity(1), lineWidth: 1.5)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(formattedDate)
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.95))

                Text(run.title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)

                HStack {
                    badge(run.subtitle)
                }
            }
            .padding(.horizontal, 12)
            Spacer()
        }
        .background(Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(minWidth: 392, maxWidth: 302, minHeight: 114, maxHeight: .infinity)
    }
}

#Preview {
    RunningSessionCard()
}
