import SwiftUI

struct HeartRateZoneSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    // Data model for the zones
    let zones: [ZoneInfo] = [
        ZoneInfo(
            id: 1,
            title: "Zone 1: Warm Up",
            description: "Used for warming up, cooling down, and easing your body into or out of training with low, steady effort.",
            bpm: "120 bpm"
        ),
        ZoneInfo(
            id: 2,
            title: "Zone 2: Endurance",
            description: "Builds aerobic fitness and burns fat efficiently while keeping fatigue low, letting you sustain longer sessions.",
            bpm: "130 bpm"
        ),
        ZoneInfo(
            id: 3,
            title: "Zone 3: Moderate",
            description: "Improves overall cardiovascular strength and muscle performance through a steady, manageable intensity.",
            bpm: "150 bpm"
        ),
        ZoneInfo(
            id: 4,
            title: "Zone 4: Intense",
            description: "Boosts speed endurance and helps your body adapt to higher lactic acid levels during harder efforts.",
            bpm: "170 bpm"
        ),
        ZoneInfo(
            id: 5,
            title: "Zone 5: Performance",
            description: "Maximal effort where your heart and lungs work at full capacity. Great for short, powerful bursts to increase peak performance. Don't stay in this zone for too long.",
            bpm: "190 bpm"
        )
    ]
    
    var body: some View {
        ZStack {
            // Background Color
            Color("black-500")
                .background(Color("black-500"))
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // 1. Header with Close Button
                HStack {
                    Spacer()
                    Text("Heart Rate Zones")
                        .font(.custom("Helvetica Neue", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // 2. Description Text
                        Text("Monitoring heart rate (HR) is a metric used to determine training activity. There is a close correlation between the activity and heart rate. HR training zones are needed to define the activity's strenuosity.")
                            .font(.custom("Helvetica Neue", size: 17))
                            .foregroundColor(.white)
                            .lineSpacing(2)
                        
                        // 3. Your Zones Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Zones:")
                                .font(.custom("Helvetica Neue", size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Heart rate zones below are calculated based on your maximum HR ")
                                .font(.custom("Helvetica Neue", size: 17))
                                .foregroundColor(Color("black-100")) +
                            Text("199 bpm")
                                .font(.custom("Helvetica Neue", size: 17))
                                .underline()
                                .foregroundColor(Color("black-100")) +
                            Text(" and resting HR 78 bpm.")
                                .font(.custom("Helvetica Neue", size: 17))
                                .foregroundColor(Color("black-100"))
                        }
                        .padding(.top, 8)
                        
                        // 4. Zone Cards Loop
                        ForEach(zones) { zone in
                            HeartRateZoneCard(zone: zone)
                        }
                        
                        Spacer().frame(height: 20)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Reusable Card Component
struct HeartRateZoneCard: View {
    let zone: ZoneInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(zone.title)
                .font(.custom("Helvetica Neue", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(alignment: .bottom) {
                // Description
                Text(zone.description)
                    .font(.custom("Helvetica Neue", size: 17))
                    .foregroundColor(Color(UIColor.lightGray))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true) // wrap text
                
                Spacer(minLength: 4)
                
                // BPM
                Text(zone.bpm)
                    .font(.custom("Helvetica Neue", size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .layoutPriority(1)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("black-475")) // Dark card background
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("black-400"), lineWidth: 1)
                )
        )
    }
}

// MARK: - Data Model
struct ZoneInfo: Identifiable {
    let id: Int
    let title: String
    let description: String
    let bpm: String
}

// MARK: - Preview
#Preview {
    HeartRateZoneSheetView()
        .preferredColorScheme(.dark)
}
