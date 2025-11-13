//
//  ButtonModifier.swift
//  Coursa
//
//  Created by Zikar Nurizky on 29/10/25.
//
import Foundation
import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    var isDisabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(24)
            .frame(width: 362, height: 54)
            .background(isDisabled ? Color("white-700") : (configuration.isPressed ? Color("white-500") : Color("white-500")))
            .foregroundColor(isDisabled ? Color("black-400") : Color("black-500"))
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.96 : 1)
            .disabled(isDisabled)
    }
}
