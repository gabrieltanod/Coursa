//
//  MediaGridView.swift
//  Fico
//
//  Created by Gabriel Tanod on 13/10/25.
//

import SwiftUI

// MARK: - MediaGridView

struct MediaGridView: View {
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<2, id: \.self) { index in
                RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: LayoutConstants.mediaTileSize, height: LayoutConstants.mediaTileSize)
                    .overlay(
                        Image(systemName: "play.circle")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                    )
                    .accessibilityLabel("Media content \(index + 1)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MediaGridView()
        .padding()
}
