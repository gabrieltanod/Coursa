//
//  HeaderTimerViewModel.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 28/10/25.
//

import SwiftUI
import Combine

class HeaderTimerViewModel: ObservableObject {
    
    @Published var timeElapsed: Double = 0.0
    @Published var isRunning: Bool = false
    @Published var timer: Timer?
    
    func formattedTime() -> String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        let milliseconds = Int((timeElapsed.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d,%02d", minutes, seconds, milliseconds)
    }
    
    func toggleStartPause() {
        if isRunning { pause() } else { start() }
        isRunning.toggle()
    }
    
    func start() {
        timer?.invalidate()
        let newTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.timeElapsed += 0.01
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        timeElapsed = 0.0
        isRunning = false
    }
}

