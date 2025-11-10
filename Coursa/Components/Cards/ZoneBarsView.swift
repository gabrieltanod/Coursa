//
//  ZoneBarsView.swift
//  Coursa
//
//  Created by Zikar Nurizky on 11/11/25.
//

import SwiftUI

struct ZoneData: Identifiable {
    let id = UUID()
    let label: String
    let time: String?
}

struct ZoneBar: View {
    let label: String
    let time: String?
    let width: CGFloat
    let isHighest: Bool
    var gradientHighest: LinearGradient {
        let _: [Color] = [
            Color("green-gradient-low"), Color("green-gradient-high"),
        ]
        let stops: [Gradient.Stop] = [
            .init(color: Color("green-gradient-low"), location: 0.1312),
            .init(color: Color("green-gradient-high"), location: 2.9781),
        ]
        let startPoint: UnitPoint = .init(x: 0.3, y: 0.35)
        let endPoint: UnitPoint = .init(x: 0.75, y: 1.7)

        return LinearGradient(
            stops: stops,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
    var gradient: LinearGradient {
        let _: [Color] = [Color("black-400"), Color("gray-gradient")]
        let stops: [Gradient.Stop] = [
            .init(color: Color("black-400"), location: 0.1312),
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

    var body: some View {
        HStack {
            Text(label)
                .font(.custom("Helvetica Neue", size: 16))
                .foregroundColor(isHighest ? Color("black-500") : .white)

            Spacer()

            if let time = time {
                Text(time)
                    .font(.custom("Helvetica Neue", size: 16))
                    .foregroundColor(isHighest ? Color("black-500") : .white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .frame(maxWidth: width)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isHighest ? gradientHighest : gradient)
        )
        .animation(.easeInOut(duration: 0.3), value: width)
        .animation(.easeInOut(duration: 0.3), value: isHighest)
    }
}

struct ZoneBarsView: View {
    let zones = [
        ZoneData(label: "Zone 1", time: "4:32"),
        ZoneData(label: "Zone 2", time: "15:32"),
        ZoneData(label: "Zone 3", time: "2:32"),
        ZoneData(label: "Zone 4", time: nil),
        ZoneData(label: "Zone 5", time: nil),
    ]

    // Convert time string to seconds
    private func timeToSeconds(_ timeStr: String?) -> Int {
        guard let timeStr = timeStr else { return 0 }
        let components = timeStr.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return 0 }
        return components[0] * 60 + components[1]
    }

    // Calculate maximum time value
    private var maxTime: Int {
        zones.map { timeToSeconds($0.time) }.max() ?? 0
    }

    // Calculate width for each bar
    private func getWidth(for time: String?, maxWidth: CGFloat) -> CGFloat {
        guard let time = time else { return maxWidth * 0.3 }  // 30% for bars without values

        let seconds = timeToSeconds(time)
        guard maxTime > 0 else { return maxWidth * 0.4 }

        // Map to 40-100% range
        let percentage = 0.4 + (Double(seconds) / Double(maxTime)) * 0.6
        return maxWidth * CGFloat(percentage)
    }

    // Check if this zone has the highest value
    private func isHighest(_ zone: ZoneData) -> Bool {
        guard maxTime > 0 else { return false }
        return timeToSeconds(zone.time) == maxTime
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 12) {
                ForEach(zones) { zone in
                    ZoneBar(
                        label: zone.label,
                        time: zone.time,
                        width: getWidth(
                            for: zone.time,
                            maxWidth: geometry.size.width
                        ),
                        isHighest: isHighest(zone)
                    )
                }
            }
        }
        .frame(height: 347)
    }
}

#Preview {
    ZoneBarsView()
}
