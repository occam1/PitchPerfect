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
    let audioSessionManager = AudioSessionManager.shared
    let speechify = TTSManager.shared
    var playing = true
    var elapsedTime = 0.0
    var startTime = Date()
    // Existing properties
    @Published var generatedFrequency: Float = 440.0 // Example: A4
    @Published var currentNoteLabel: String = "A4" // Default note
    @Published var matchResult: String = "Waiting for input..."
    @Published var detectedFrequencies: [Float] = [] // Track the last 5 detected frequencies
    // Playback control state
    @Published var isAutomatic: Bool = true // Automatic playback mode
    @Published var isPaused: Bool = false // Playback paused state
    @Published var isPlayingTone: Bool = false // Tone Player is playing a tone
    let maxVisibleLines = 5 // Number of lines visible at a time
    var lastFeedback: String? = nil
    
    @Published var detectedSampleRate: Double
    @Published var fftSize: Int

    private init() {
        self.detectedSampleRate = audioSessionManager.audioSession.sampleRate
        self.fftSize = 32768  // Default; can be adjusted dynamically
        print("🔍 Detected Sample Rate: \(detectedSampleRate)")
        print("PitchCompareModel initialized")
    }
    // Update detected frequency
    func updateDetectedFrequency(_ frequency: Float) {
        DispatchQueue.main.async {
            self.detectedFrequencies.append(frequency)
            if self.detectedFrequencies.count > self.maxVisibleLines {
                self.detectedFrequencies.removeFirst(self.detectedFrequencies.count - self.maxVisibleLines)
            }
            if self.playing
            {
                self.matchResult = self.comparePitches(target: self.generatedFrequency, detected: frequency)
            }
        }
        
    }
    func updateGeneratedFrequency(to frequency: Float , label: String , play: Bool) {
        self.playing = play
        lastFeedback = nil
        self.generatedFrequency = frequency
        self.currentNoteLabel = label
        print("PCM UpdtLbl currentNoteLabel, \(self.currentNoteLabel) , \(self.generatedFrequency)")
    }


    // Compare detected frequency with the target
    private func comparePitches(target: Float, detected: Float) -> String {
        let tolerance: Float = 5.0 // Allowable cents difference
        let diff = abs(target - detected)
        
        // Perform some task
      
        
      //  print("Elapsed time: \(elapsedTime) seconds")
        if diff < tolerance {
          //let elapsedTime = Date().timeIntervalSince(startTime)
          //if elapsedTime > 0.5 {
          //    speechify.speak("good")
          //    lastFeedback = "good"
          //    startTime = Date()
          // }
            return "Matched"
        } else if detected > target  {
          // if lastFeedback != "sharp"  {
          //     speechify.speak("sharp")
          //     lastFeedback = "sharp"
          //  }
            return "Sharp"
        } else {
          // if  lastFeedback != "flat" {
          //     speechify.speak("flat")
          //     lastFeedback = "flat"
          // }
            return "Flat"
        }
    }
}
