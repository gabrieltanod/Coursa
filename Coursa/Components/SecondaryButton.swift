//
//  SecondaryButton.swift
//  Coursa
//
//  Created by Gabriel Tanod on 11/11/25.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.black)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(Color.white)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
