//
//  ZoneBarView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 28/10/25.
//

import SwiftUI

enum HRZone: Int, CaseIterable {
    case zone1, zone2, zone3, zone4, zone5
}

struct ZoneBarRSView: View {
    // 1. DATA INPUT
    let zoneNumber: Int
    let timeInSeconds: Double
    let maxTimeInSeconds: Double // Waktu terpanjang di antara semua zona
    let maxWidth: CGFloat       // Lebar penuh layar dari GeometryReader
    
    let maxHR: Double = 198       // Lebar penuh layar dari GeometryReader
    
    
    @EnvironmentObject var workoutManager: WorkoutManager
    
    // 2. LOGIKA INTERNAL
    
    private var barColor: Color {
        // Tentukan warna berdasarkan zona
        switch zoneNumber {
        case 1...3:
            // Ganti "customPurple" dengan nama aset Anda
            // Kecuali Zone 2 yang kuning
            return zoneNumber == 2 ? Color("secondary") : Color("accent")
        case 4...5:
            // Ganti "customOrange" dengan nama aset Anda
            return Color("accentSecondary")
        default:
            return Color.gray
        }
    }
    
    private var timeString: String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // --- LOGIKA LEBAR DINAMIS (YANG DIPERBAIKI) ---
    private var barWidth: CGFloat {
        
        // Lebar minimum HANYA untuk "Zone X" (misal: Zone 4, 5)
        let minLabelWidth: CGFloat = 70
        
        // Lebar minimum untuk "Zone X" + "MM:SS" (misal: Zone 1, 3)
        let minDataWidth: CGFloat = 120
        
        if timeInSeconds == 0 {
            // Jika tidak ada waktu, gunakan lebar minimum
            return minLabelWidth
        }
        
        // --- Perhitungan Proporsional ---
        
        // 1. Tentukan lebar "dasar" (minimum yang diizinkan untuk data)
        let baseWidth = minDataWidth
        
        // 2. Hitung sisa lebar yang tersedia untuk bertambah
        let availableWidth = maxWidth - baseWidth
        
        // 3. Hitung persentase waktu
        let timePercentage = maxTimeInSeconds > 0 ? (timeInSeconds / maxTimeInSeconds) : 0
        
        // 4. Hitung lebar ekstra berdasarkan persentase
        let extraWidth = availableWidth * timePercentage
        
        // 5. Lebar total adalah lebar dasar + lebar ekstra
        // Ini memastikan Zone 2 (100%) akan mengisi 'maxWidth'
        // dan Zone 1 & 3 akan proporsional di antaranya.
        return baseWidth + extraWidth
    }

    // 3. TAMPILAN (BODY)
    var body: some View {
        switch workoutManager.heartRate =
//        HStack {
//            Text("Zone \(zoneNumber)")
//            
//            Spacer()
//            
//            // Tampilkan waktu HANYA jika lebih dari 0
//            if timeInSeconds > 0 {
//                Text(timeString)
//            }
//        }
//        .font(.system(size: 14, weight: .semibold))
//        // Teks hitam untuk bar kuning (Zone 2), sisanya putih
//        .foregroundColor(zoneNumber == 2 ? Color("app") : Color("primary"))
//        .padding(.horizontal, 8)
//        .frame(width: barWidth, alignment: .leading) // Terapkan lebar dinamis
//        .background(barColor)
//        .clipShape(Capsule()) // Membuat sudutnya bulat
    }
}

#Preview {
    ZoneBarRSView(zoneNumber: 2, timeInSeconds: 2002, maxTimeInSeconds: 1000, maxWidth: 100)
}
