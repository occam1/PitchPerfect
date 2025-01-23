//
//  GetTone.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//

import AVFoundation

class ToneGetter {
    private let audioEngine = AVAudioEngine()
    private let fftAnalyzer = FFTAnalyzer()
    private let pitchCompareModel: PitchCompareModel

    init(model: PitchCompareModel) {
        self.pitchCompareModel = model
    }

    func startCapture() {
        configureAudioSession() // Ensure the audio session is configured

        let audioSession = AVAudioSession.sharedInstance()
        guard audioSession.isInputAvailable else {
            print("Audio input not available.")
            return
        }

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0) // Use the hardware's input format
        print("Input Format: \(inputFormat)")

        inputNode.installTap(onBus: 0, bufferSize: 512, format: inputFormat) { buffer, _ in
            if let dominantFrequency = self.fftAnalyzer.analyze(buffer: buffer) {
                DispatchQueue.main.async {
                    self.pitchCompareModel.updateDetectedFrequency(dominantFrequency)
                }
            }
        }

        do {
            try audioEngine.start()
            print("Audio engine started successfully.")
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    func stopCapture() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}
