//
//  PitchCompareModel.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//
import Foundation
import Combine

class PitchCompareModel: ObservableObject {
    @Published var generatedFrequency: Float = 440.0 // Example: A4
    @Published var detectedFrequency: Float = 0.0
    @Published var currentNoteLabel: String = "A4" // Default note
    @Published var matchResult: String = "Waiting for input..."

    // Computed properties for UI
    var generatedToneY: CGFloat {
        return mapFrequencyToYPosition(generatedFrequency)
    }

    var sungToneY: CGFloat? {
        return detectedFrequency > 0 ? mapFrequencyToYPosition(detectedFrequency) : nil
    }

    func updateDetectedFrequency(_ frequency: Float) {
        detectedFrequency = frequency
        matchResult = comparePitches(target: generatedFrequency, detected: frequency)
    }

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

    private func mapFrequencyToYPosition(_ frequency: Float) -> CGFloat {
        let minFreq: Float = 110.0 // A2
        let maxFreq: Float = 880.0 // A5

        return CGFloat((frequency - minFreq) / (maxFreq - minFreq))
    }
}
