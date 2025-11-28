//
//  WatchConfirmationView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 28/11/25.
//

import SwiftUI

struct WatchConfirmationView: View {
    let run: ScheduledRun
    let onStartRun: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.13, green: 0.12, blue: 0.12)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with back button and title
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text(run.title)
                        .font(.custom("Helvetica Neue", size: 18, relativeTo: .headline))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible spacer to balance the layout
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                // Watch icon
                Image(systemName: "applewatch")
                    .font(.system(size: 80, weight: .regular))
                    .foregroundColor(.gray)
                
                Spacer()
                    .frame(height: 40)
                
                // Instruction text
                Text("Make sure your watch is ready before your run. All your running data will sync automatically.")
                    .font(.custom("Helvetica Neue", size: 16, relativeTo: .body))
                    .fontWeight(.regular)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                Spacer()
                
                // Start Run button
                Button(action: onStartRun) {
                    Text("Start Run")
                        .font(.custom("Helvetica Neue", size: 17, relativeTo: .body))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 0.78, green: 1.0, blue: 0.0))
                        .cornerRadius(28)
                }
            }
        }
//        .frame(width: 440, height: 956)
        .background(Color(red: 0.13, green: 0.12, blue: 0.12))
    }
}

#Preview {
    let sampleTemplate = RunTemplate(
        name: "MAF Training",
        kind: .maf,
        focus: .endurance,
        targetDurationSec: 1800,
        targetDistanceKm: 5.0,
        targetHRZone: .z2,
        notes: ""
    )
    
    let sampleRun = ScheduledRun(
        date: Date(),
        template: sampleTemplate,
        status: .planned
    )
    
    return WatchConfirmationView(run: sampleRun, onStartRun: {})
        .preferredColorScheme(.dark)
}
