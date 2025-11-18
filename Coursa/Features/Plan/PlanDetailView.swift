//
//  PlanDetailView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 28/10/25.
//

import SwiftUI

struct PlanDetailView: View {
    let run: ScheduledRun
    @Environment(\.dismiss) private var dismiss
    @State private var isRunning = false
    @State private var didComplete = false
    @State private var showingInfoSheet = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color("black-500").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header image + overlay + text
                    GeometryReader { geo in
                        ZStack(alignment: .bottom) {
                            Image("CoursaImages/Running_Easy")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                                .overlay(
                                    ZStack {
                                        overlayColor.opacity(0.55)
                                        LinearGradient(
                                            colors: [.clear, Color("black-500")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    }
                                )
                            
                            VStack(alignment: .center) {
                                Text(formattedDate)
                                    .font(.custom("Helvetica Neue", size: 14))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.bottom, 11)
                                
                                Text(run.title)
                                    .font(.custom("Helvetica Neue", size: 34))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.bottom, 17)
                                
                                metricsRow
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 32)
                        }
                        //                        .frame(height: geo.size.height)
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                    
                    // Body content
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(spacing: 8) {
                            SmallCard {
                                VStack(alignment: .leading){
                                    Text("Keep conversational")
                                        .font(.custom("Helvetica Neue", size: 14))
                                        .foregroundColor(.white)
                                    
                                    HStack(alignment: .center, spacing: 5) { // <-- Use center alignment
                                        Text("pace for")
                                            .font(.custom("Helvetica Neue", size: 14))
                                            .foregroundColor(.white)
                                        
                                        Button {
                                            showingInfoSheet.toggle()
                                        } label: {
                                            Image(systemName: "info.circle")
                                                .font(.custom("Helvetica Neue", size: 12))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                Spacer()
                                
                                Text(conversationalPaceMinutesText)
                                    .font(.custom("Helvetica Neue", size: 28))
                                    .foregroundColor(Color("green-500"))
                                    .bold()
                            }
                            
                            
                            SmallCard {
                                Text("Recommended Pace")
                                    .lineLimit(2, reservesSpace: true)
                                    .font(.custom("Helvetica Neue", size: 16))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("7:30/km")
                                    .font(.custom("Helvetica Neue", size: 28))
                                    .foregroundColor(Color("green-500"))
                                    .bold()
                            }
                        }
                        
                        VStack (alignment: .leading, spacing: 8){
                            Text("Description")
                                .font(.custom("Helvetica Neue", size: 20))
                                .foregroundColor(.white)
                            
                            Text(descriptionText)
                                .font(.custom("Helvetica Neue", size: 15))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading) // Ensure text aligns to the left
                                .lineLimit(nil) // Allow unlimited lines
                                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            
            VStack {
                Button {
                    // TODO: Implement the navigation/logic for the "Let's Go" button here.
                } label: {
                    Text("Let's Go")
                        .font(.custom("Helvetica Neue", size: 17))
                        .foregroundColor(Color.black)
                }
                .frame(maxWidth: .infinity, minHeight: 54, alignment: .center)
                .background(Color.white)
                .cornerRadius(20)
                //                        .controlSize(.large) // Make it prominent
                .padding(.top, 10) // Add padding for safety margin from the screen edge
                .padding(.bottom, 40) // Add padding for safety margin from the screen edge
                .padding(.horizontal) // Optional: Add padding on the sides
                .background(.ultraThinMaterial)
            }
            .frame(maxWidth: .infinity) // Ensure the container spans the full width
            //                        .background(.ultraThinMaterial) // Optional: Add a subtle background blur for contrast
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingInfoSheet) {
            // Your Half-Screen Modal Content
            RunningNotesModalView()
                .presentationDetents([.fraction(0.35)])
        }
    }
    
    // Metrics row under title
    private var metricsRow: some View {
        HStack(spacing: 20) {
            if let dur = run.template.targetDurationSec {
                Label {
                    Text(Self.mmText(dur))
                } icon: {
                    Image(systemName: "clock.fill")
                }
            }
            Text("|")
            if let z = run.template.targetHRZone {
                Label {
                    Text("Heart Rate Zone \(z.rawValue)")
                    
                } icon: {
                    Image(systemName: "heart.fill")
                }
            }
        }
        .font(.custom("Helvetica Neue", size: 15))
        .foregroundColor(Color("white-500"))
        .labelStyle(.titleAndIcon)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: run.date)
    }
    
    private var descriptionText: String {
        if let notes = run.template.notes, !notes.isEmpty {
            return notes
        } else {
            return
            "This session is designed to support your endurance with controlled effort and clear structure. Run at a comfortable pace, stay relaxed, and focus on finishing strong."
        }
    }
    
    // Color tint for header image based on run kind
    private var overlayColor: Color {
        switch run.template.kind {
        case .easy:
            return Color("easy")
        case .long:
            return Color("long")
        case .maf:
            return Color("maf")
        case .tempo:
            return Color("maf")
        case .intervals:
            return Color("maf")
        case .recovery:
            return Color("easy")
        }
    }
    
    private static func mmText(_ seconds: Int) -> String {
        let m = seconds / 60
        return "\(m) min"
    }
    
    private var conversationalPaceMinutesText: String {
        if let dur = run.template.targetDurationSec {
            let m = dur / 60
            return "\(m) min"
        } else {
            return "-- min"
        }
    }
}

#Preview("Plan Detail") {
    let sampleTemplate = RunTemplate(
        name: "Easy Run",
        kind: .easy,
        focus: .base,
        targetDurationSec: 1800,
        targetDistanceKm: 3.0,
        targetHRZone: .z2,
        notes:
            "This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats."
    )
    
    let sampleRun = ScheduledRun(
        date: Date(),
        template: sampleTemplate,
        status: .planned
    )
    
    return NavigationStack {
        PlanDetailView(run: sampleRun)
            .preferredColorScheme(.dark)
    }
}
