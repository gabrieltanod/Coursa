//
//  ButtonChip.swift
//  Coursa
//
//  Created by Zikar Nurizky on 30/10/25.
//

import SwiftUI

struct ButtonChip: View {
    var text: String
    var body: some View {
        HStack {
            Text(text)
        }
        .customChipModifier()
        .contentShape(Rectangle())

    }
}

#Preview {
    ButtonChip(text: "5 KM")
}
