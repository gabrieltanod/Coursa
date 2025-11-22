//
//  ReviewSheet.swift
//  Coursa
//
//  Created by Gabriel Tanod on 20/11/25.
//

import SwiftUI

struct ReviewPlanSheet: View {
    let onDismiss: () -> Void
    let onAdjust: () -> Void
    let onKeepCurrent: () -> Void
    
    /// Rows driving the "This Week Performance" table.
    /// Later you can pass real data derived from your plan / summaries.
    let rows: [ReviewSessionRow]
    
    struct ReviewSessionRow: Identifiable {
        let id = UUID()
        let session: String
        let distanceText: String
        let heartRateText: String
        let isDone: Bool
    }
    func makeHighlightCaption() -> AttributedString {
        var string = AttributedString(
            "Your distance goal this week is 15km. We can adjust the plan to better align with your current performance. This helps you stay on track and build momentum."
        )

        if let range = string.range(of: "align with your current performance") {
            var container = AttributeContainer()
            container.foregroundColor = Color("green-500")
            container.font = .custom("Helvetica Neue", size: 14)
            string[range].setAttributes(container)
        }

        return string
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .center, spacing: 24) {
                    // Header row with title and X
                    VStack(spacing: 8) {
                        Text("Recommended Weekly Distance")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            Text("13KM")
                                .font(.system(size: 64, weight: .medium))
                                .foregroundColor(.white)
                            Image(systemName: "arrow.down")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Highlight block
                    VStack(alignment: .leading, spacing: 6) {
                        Text(makeHighlightCaption())
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(18)
                    
                    // This Week Performance
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This Week Performance")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                        
                        // Header row
                        HStack(spacing: 0) {
                            Text("Sessions")
                                .font(.system(size: 12))
                                .foregroundColor(Color("black-200"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Distance (km)")
                                .font(.system(size: 12))
                                .foregroundColor(Color("black-200"))
                                .frame(width: 90, alignment: .center)
                            
                            Text("Heart Rate (bpm)")
                                .font(.system(size: 12))
                                .foregroundColor(Color("black-200"))
                                .frame(width: 100, alignment: .center)
                            
                            Text("Status")
                                .font(.system(size: 12))
                                .foregroundColor(Color("black-200"))
                                .frame(width: 50, alignment: .center)
                        }
                        
                        // Data rows
                        ForEach(rows) { row in
                            HStack(spacing: 0) {
                                Text(row.session)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                
                                Text(row.distanceText)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .frame(width: 90, alignment: .center)
                                
                                Text(row.heartRateText)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .frame(width: 100, alignment: .center)
                                
                                Image(systemName: row.isDone ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(row.isDone ? Color("green-500") : .red)
                                    .frame(width: 50, alignment: .center)
                            }
                            .frame(height: 24)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            
            // Buttons fixed at bottom
            VStack(spacing: 10) {
                Button(action: onAdjust) {
                    Text("Adjust Plan")
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button(action: onKeepCurrent) {
                    Text("Keep current plan")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .inset(by: 0.5)
                                .stroke(.white, lineWidth: 1)

                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
            .background(Color("black-500"))
        }
        .navigationTitle("Review Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(8)
                        .foregroundColor(.white)
                }
            }
        }
        //        .background(Color("black-500")) // sheet background
    }
    
}

#Preview {
    ReviewPlanSheet(
        onDismiss: { print("Dismiss tapped") },
        onAdjust:  { print("Adjust tapped") },
        onKeepCurrent: { print("Keep current tapped") },
        rows: [
            .init(session: "MAF Training", distanceText: "-", heartRateText: "131", isDone: true),
            .init(session: "Easy Run", distanceText: "4", heartRateText: "140", isDone: true),
            .init(session: "Long Run", distanceText: "7", heartRateText: "153", isDone: false)
        ]
    )
    .preferredColorScheme(.dark)
    .background(Color.black)
}
