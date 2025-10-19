//
//  ProgressCardView.swift
//  Fico
//
//  Created by Gabriel Tanod on 13/10/25.
//

import SwiftUI

// MARK: - ProgressCardView

struct ProgressCardView: View {
    let title: String
    let progress: Double
    let caption: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "envelope")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
                .accessibilityLabel("Progress details")
            }
            
            // Progress bar
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    Rectangle()
                        .fill(index < Int(progress * 5) ? Color.gray : Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            Text(caption)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(caption)")
    }
}

// MARK: - Preview

#Preview {
    ProgressCardView(
        title: "Lorem Ipsum",
        progress: 0.6,
        caption: "Lorem ipsum : xx KM"
    )
    .padding()
}
