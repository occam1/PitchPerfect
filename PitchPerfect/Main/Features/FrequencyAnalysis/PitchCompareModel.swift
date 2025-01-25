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
    @Published var detectedFrequency: Float = 0.0
    @Published var currentNoteLabel: String = "A4" // Default note
    @Published var matchResult: String = "Waiting for input..."

    // New property for moving lines
    @Published var lines: [FrequencyLine] = [] // Holds the lines to display
    let maxVisibleLines = 5 // Number of lines visible at a time

    // Computed properties for UI
    var generatedToneY: CGFloat {
        return mapFrequencyToYPosition(generatedFrequency)
    }

    var sungToneY: CGFloat? {
        return detectedFrequency > 0 ? mapFrequencyToYPosition(detectedFrequency) : nil
    }

    // Update detected frequency and add it as a line
    func updateDetectedFrequency(_ frequency: Float) {
        detectedFrequency = frequency
        print("PCM detectedFrequency: \(detectedFrequency)")
        matchResult = comparePitches(target: generatedFrequency, detected: frequency)
        addFrequencyLine(frequency: frequency) // Add frequency line
    }

    // Add a frequency line to the model
    public func addFrequencyLine(frequency: Float) {
        print("PCM AL frequency, \(frequency)")
        let normalizedFrequency = mapFrequencyToYPosition(frequency)
        let line = FrequencyLine(yPosition: normalizedFrequency)
        DispatchQueue.main.async {
            self.lines.append(line)
            if self.lines.count > self.maxVisibleLines {
                self.lines.removeFirst(self.lines.count - self.maxVisibleLines)
            }
        }
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

    // Map a frequency to a Y-position for display
    private func mapFrequencyToYPosition(_ frequency: Float) -> CGFloat {
        let minFreq: Float = 110.0 // A2
        let maxFreq: Float = 880.0 // A5

        return CGFloat((frequency - minFreq) / (maxFreq - minFreq))
    }
}

// Helper struct for frequency lines
struct FrequencyLine: Identifiable {
    let id = UUID()
    let yPosition: CGFloat
}
