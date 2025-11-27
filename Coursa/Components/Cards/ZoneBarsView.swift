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
    let seconds: Double
}

struct ZoneBar: View {
    let label: String
    let seconds: Double
    let width: CGFloat
    let isHighest: Bool
    
    // MARK: - Gradients
    var gradientHighest: LinearGradient {
        let color1 = Color(red: 218/255, green: 255/255, blue: 2/255)
        let color2 = Color(red: 131/255, green: 153/255, blue: 1/255)
        
        let stops: [Gradient.Stop] = [
            .init(color: color1, location: -0.0296),
            .init(color: color2, location: 1.1807),
        ]
        let startPoint: UnitPoint = .init(x: 1.0, y: 0.1)
        let endPoint: UnitPoint = .init(x: 0.0, y: 0.9)
        
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
                .font(.custom("Helvetica Neue", size: 16, relativeTo: .body))
                .foregroundColor(seconds > 0 ? (isHighest ? Color("black-500") : .white)  : Color("black-300"))
            
            Spacer()
            
            if seconds > 0 {
                Text(formatSeconds(seconds))
                    .font(.custom("Helvetica Neue", size: 16, relativeTo: .body))
                    .foregroundColor(isHighest ? Color("black-500") : .white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: width)
        .background {
            if seconds > 0 {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isHighest ? gradientHighest : gradient)
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color("black-gradient2"))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: width)
        .animation(.easeInOut(duration: 0.3), value: isHighest)
    }
    
    private func formatSeconds(_ sec: Double) -> String {
        if sec <= 0 { return "0:00" }
        let m = Int(sec) / 60
        let s = Int(sec) % 60
        return String(format: "%d:%02d min", m, s)
    }
}

struct ZoneBarsView: View {
    
    let run: ScheduledRun
    
    private var zoneDurationInt: [Int: Double] {
        run.actual.zoneDuration
    }
    
    private var zones: [ZoneData] {
        (1...5).map { zone in
            let sec = zoneDurationInt[zone] ?? 0
            return ZoneData(label: "Zone \(zone)", seconds: sec)
        }
    }
    
    private var maxSeconds: Double {
        zones.map { $0.seconds }.max() ?? 0
    }
    
    private var totalSeconds: Double {
        zones.map { $0.seconds }.reduce(0, +)
    }
    
    private func getWidth(seconds: Double, maxWidth: CGFloat) -> CGFloat {
        if seconds <= 0 {
            return 90
        }
        
        guard maxSeconds > 0 else { return 170 }
        let percentage = 0.4 + (seconds / maxSeconds) * 0.6
        let calculatedWidth = maxWidth * CGFloat(percentage)
        
        let minContentWidth: CGFloat = 170
        
        return max(calculatedWidth, minContentWidth)
    }
    
    private func isHighest(_ zone: ZoneData) -> Bool {
        guard maxSeconds > 0 else { return false }
        return zone.seconds == maxSeconds
    }
    
    private func percentageString(for seconds: Double) -> String {
        guard totalSeconds > 0 else { return "0%" }
        let val = Int((seconds / totalSeconds) * 100)
        return "\(val)%"
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 12) {
                ForEach(zones) { zone in
                    HStack(spacing: 12) {
                        ZoneBar(
                            label: zone.label,
                            seconds: zone.seconds,
                            width: getWidth(seconds: zone.seconds, maxWidth: geometry.size.width - 45),
                            isHighest: isHighest(zone)
                        )
                        
                        Text(percentageString(for: zone.seconds))
                            .font(.custom("Helvetica Neue", size: 16, relativeTo: .body))
                            .fontWeight(.medium)
                            .foregroundStyle(zone.seconds > 0 ? .white : Color("black-300"))
                            .frame(width: 45, alignment: .leading)
                    }
                }
            }
        }
        .frame(height: CGFloat(zones.count) * 37 + CGFloat(zones.count - 1) * 12)
    }
}
