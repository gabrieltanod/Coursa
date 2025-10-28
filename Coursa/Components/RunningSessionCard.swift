//
//  RunningSessionCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 27/10/25.
//

import SwiftUI

struct RunningSessionCard: View {
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text("Tue, 21 October 2025")
                    .font(.caption)
                    .padding(.vertical, 12)
                Text("Easy Run")
                    .font(.headline)
                    .padding(.bottom, 12)
                Text("3 KM")
                    .font(.caption)
                Text("HR Zone 2")
                    .font(.caption)
                    .padding(.bottom, 12)
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
