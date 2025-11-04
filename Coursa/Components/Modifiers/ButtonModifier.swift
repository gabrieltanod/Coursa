//
//  ButtonModifier.swift
//  Coursa
//
//  Created by Zikar Nurizky on 29/10/25.
//

import Foundation
import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(24)
            .frame(width: 362, height: 54)
            .background(configuration.isPressed ? Color("white-500") : Color("white-500"))
            .foregroundColor(Color("black-500"))
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}
