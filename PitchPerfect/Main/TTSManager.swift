//
//  Speech.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/28/25.
//
import AVFoundation

class TTSManager {
    static let shared = TTSManager() // Singleton instance
    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speak(_ text: String) {
        // Check if the synthesizer is already speaking
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate) // Stop the current speech
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Adjust language if needed
        utterance.rate = 0.5 // Adjust speed (default is 0.5)
        utterance.volume = 0.5 // Full volume

        synthesizer.speak(utterance)
    }
}
