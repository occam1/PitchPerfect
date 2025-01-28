//
//  PitchCompareModel.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//
import Foundation
import Combine

class PitchCompareModel: ObservableObject {
    static let shared = PitchCompareModel() // Singleton instance

    // Existing properties
    @Published var generatedFrequency: Float = 440.0 // Example: A4
    @Published var currentNoteLabel: String = "A4" // Default note
    @Published var matchResult: String = "Waiting for input..."
    @Published var detectedFrequencies: [Float] = [] // Track the last 5 detected frequencies
    // Playback control state
    @Published var isAutomatic: Bool = true // Automatic playback mode
    @Published var isPaused: Bool = false // Playback paused state
    let maxVisibleLines = 5 // Number of lines visible at a time
    init() {
        print("PitchCompareModel initialized")
    }
    // Update detected frequency
    func updateDetectedFrequency(_ frequency: Float) {
        DispatchQueue.main.async {
            self.detectedFrequencies.append(frequency)
            if self.detectedFrequencies.count > self.maxVisibleLines {
                self.detectedFrequencies.removeFirst(self.detectedFrequencies.count - self.maxVisibleLines)
            }
            self.matchResult = self.comparePitches(target: self.generatedFrequency, detected: frequency)
        }
    }
    func updateGeneratedFrequency(to frequency: Float , label: String) {
        self.generatedFrequency = frequency
        self.currentNoteLabel = label
        print("PCM UpdtLbl currentNoteLabel, \(self.currentNoteLabel)")
    }


    // Compare detected frequency with the target
    private func comparePitches(target: Float, detected: Float) -> String {
        let tolerance: Float = 5.0 // Allowable cents difference
        let diff = abs(target - detected)

        if diff < tolerance {
            return "Matched"
        } else if detected > target {
            return "Sharp"
        } else {
            return "Flat"
        }
    }
}
