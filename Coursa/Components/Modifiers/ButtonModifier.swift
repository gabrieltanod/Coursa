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
            .background(isDisabled ? Color("black-500") : (configuration.isPressed ? Color("white-50") : Color("white-50")))
            .foregroundColor(isDisabled ? Color("black-200") : Color("black-900"))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isDisabled ? Color("black-200") : Color("white-50"), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.96 : 1)
            .disabled(isDisabled)
    }
}
