//
//  UpcomingRunSessionCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 27/10/25.
//

import SwiftUI

struct UpcomingRunSessionCard: View {
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text("Tue, 21 October 2025")
                    .font(.caption)
                    .padding(.top, 12)
                Text("Easy Run")
                    .font(.headline)
                    .padding(.vertical, 6)
                ForEach(0..<3) { _ in
                    HStack {
                        Text("Tue")
                            .font(.caption)
                        Text("Easy Run")
                            .font(.caption)
                    }
                    .padding(.bottom, 12)
                }
                
            }
            .padding(.horizontal, 12)
            Spacer()
        }
        .background(Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(minWidth: 392, maxWidth: 302, minHeight: 114, maxHeight: .infinity)
    }
}

struct WeekSummaryCard: View {
    let title: String
    let runs: [ScheduledRun]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title3).bold()
            ForEach(runs) { run in
                HStack(spacing: 12) {
                    Text(weekday(run.date))
                        .frame(width: .infinity, alignment: .leading)
                        .foregroundStyle(.secondary)
                    Text(run.title)
                }
            }
        }
        .frame(width: 392, alignment: .init(horizontal: .leading, vertical: .top))
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    private func weekday(_ date: Date) -> String {
        let df = DateFormatter(); df.setLocalizedDateFormatFromTemplate("EEE"); return df.string(from: date)
    }
}
