//
//  RunningSummaryCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 10/11/25.
//

import SwiftUI

struct RunningSummaryCard: View {

    var gradient: LinearGradient {
        let _: [Color] = [Color("black-gradient"), Color("gray-gradient")]
        let stops: [Gradient.Stop] = [
            .init(color: Color("black-gradient"), location: 0.1312),
            .init(color: Color("gray-gradient"), location: 2.9781),
        ]
        let startPoint: UnitPoint = .init(x: 0.3, y: 0.35)
        let endPoint: UnitPoint = .init(x: 0.75, y: 1.7)

        return LinearGradient(
            stops: stops,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
    var workoutType: String = "Easy Run"
    var date: String = "Wed, 25 Oct 2025 at 6.00 AM"
    var duration: String = "35:46"
    var avgHR: Int = 130
    var avgPace: Int = 130
    var distance: Float = 5.3
    
    var body: some View {
        VStack(alignment:.leading) {
            VStack (alignment: .leading){
                Text(workoutType)
                    .font(.custom("Helvetica Neue", size: 34))
                    .fontWeight(.medium)
                    .foregroundStyle(Color("white-500"))
                Text(date)
                    .font(.custom("Helvetica Neue", size: 17))
                    .fontWeight(.regular)
                    .foregroundStyle(Color("black-100"))
            }
            .padding([.top, .horizontal], 16)

            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.custom("Helvetica Neue", size: 15))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("white-500"))
                    Text(duration)
                        .font(.custom("Helvetica Neue", size: 28))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("green-400"))
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Distance")
                        .font(.custom("Helvetica Neue", size: 15))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("white-500"))
                    Text(String(format: "%.2f KM", distance))
                        .font(.custom("Helvetica Neue", size: 28))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("green-400"))
                }
            }
            .padding([.top, .horizontal],16)

            HStack {
                VStack(alignment: .leading) {
                    Text("Average HR")
                        .font(.custom("Helvetica Neue", size: 15))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("white-500"))
                    Text("\(avgHR) bpm")
                        .font(.custom("Helvetica Neue", size: 28))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("green-400"))
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Average Pace")
                        .font(.custom("Helvetica Neue", size: 15))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("white-500"))
                    Text("\(avgPace) bpm")
                        .font(.custom("Helvetica Neue", size: 28))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("green-400"))
                }
            }
            .padding(16)

        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(gradient)
        )

    }
}

#Preview {
    RunningSummaryCard()
}
