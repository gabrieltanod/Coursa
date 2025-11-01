//
//  UpcomingRunSessionCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 27/10/25.
//

import SwiftUI

struct WeekSummaryCard: View {
    let title: String
    let runs: [ScheduledRun]
    let subtitle: String?  // ← NEW

    init(title: String, runs: [ScheduledRun], subtitle: String? = nil) {
        self.title = title
        self.runs = runs
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date range inside the card (small + subtle)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("white-500"))
            }

            Text(title)
                .font(.title3).bold()
                .foregroundStyle(Color("white-500"))

            ForEach(runs) { run in
                HStack(spacing: 12) {
                    Text(weekday(run.date))
                        .frame(width: 35, alignment: .leading)
                        .foregroundStyle(Color("white-500"))
                        .font(.system(size: 15).bold())
                    
                    if run.title == "Easy Run" {
                        Text(run.title).foregroundStyle(Color("purple-500"))
                    } else if run.title == "MAF Training" {
                        Text(run.title).foregroundStyle(Color("green-500"))
                    } else if run.title == "Long Run" {
                        Text(run.title).foregroundStyle(Color("orange-500"))
                    } else {
                        Text(run.title).foregroundStyle(Color("white-500"))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding(16)
        .background(
            Color("black-450"),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private func weekday(_ date: Date) -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("EEE")
        return df.string(from: date)
    }
}
