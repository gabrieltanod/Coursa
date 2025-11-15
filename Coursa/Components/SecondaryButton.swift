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
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(Color.white)
            .padding(.horizontal, 0)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .center)
            .cornerRadius(20)
            .overlay(
            RoundedRectangle(cornerRadius: 20)
            .inset(by: 0.5)
            .stroke(.white, lineWidth: 1)

            )
    }
}
