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
    
    /// Real TRIMP-based metrics
    let recommendedDistanceKm: Double
    let currentDistanceKm: Double
    let performanceTrend: PlanAdaptationHelper.PerformanceTrend
    
    /// Rows driving the "This Week Performance" table.
    let rows: [ReviewSessionRow]
    
    struct ReviewSessionRow: Identifiable {
        let id = UUID()
        let session: String
        let distanceText: String
        let heartRateText: String
        let isDone: Bool
    }
    func makeHighlightCaption() -> AttributedString {
        let baseText: String
        let highlightPhrase: String
        
        switch performanceTrend {
        case .goodProgress:
            baseText = "Great job! Your training is progressing well. We recommend increasing your volume slightly to continue building fitness while staying safe."
            highlightPhrase = "progressing well"
        case .undertrained:
            baseText = "You've trained less than planned this week. We recommend maintaining your current volume to build consistency before increasing load."
            highlightPhrase = "maintaining your current volume"
        case .overreached:
            baseText = "You've pushed harder than planned. We recommend easing back slightly to allow proper recovery and avoid overtraining."
            highlightPhrase = "easing back slightly"
        case .maintain:
            baseText = "Your training is on track. We recommend keeping your current volume to maintain consistency and build your aerobic base."
            highlightPhrase = "keeping your current volume"
        }
        
        var string = AttributedString(baseText)
        
        if let range = string.range(of: highlightPhrase) {
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
                            Text(String(format: "%.0fKM", recommendedDistanceKm))
                                .font(.system(size: 64, weight: .medium))
                                .foregroundColor(.white)
                            
                            if performanceTrend.arrowDirection == .up {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color("green-500"))
                            } else if performanceTrend.arrowDirection == .down {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.red)
                            } else {
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
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
        recommendedDistanceKm: 27,
        currentDistanceKm: 25,
        performanceTrend: .goodProgress,
        rows: [
            .init(session: "MAF Training", distanceText: "-", heartRateText: "131", isDone: true),
            .init(session: "Easy Run", distanceText: "4", heartRateText: "140", isDone: true),
            .init(session: "Long Run", distanceText: "7", heartRateText: "153", isDone: false)
        ]
    )
    .preferredColorScheme(.dark)
    .background(Color.black)
}
