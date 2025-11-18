//
//  SmallCard.swift
//  Coursa
//
//  Created by Gabriel Tanod on 14/11/25.
//

import SwiftUI

struct SmallCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content()
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: 107, alignment: .topLeading)
        .background(Color("black-700"))
        .cornerRadius(20)
    }
}
