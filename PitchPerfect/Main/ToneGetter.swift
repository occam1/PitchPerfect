//
//  GetTone.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//

import AVFoundation

class ToneGetter {
    private let fftAnalyzer = FFTAnalyzer()
    private let pitchCompareModel: PitchCompareModel

    init(model: PitchCompareModel) {
        self.pitchCompareModel = model
    }

    func startCapture() {
        let audioSessionManager = AudioSessionManager.shared

        // Set up a callback to process audio buffers from AudioSessionManager
        audioSessionManager.audioBufferCallback = { [weak self] buffer in
            guard let self = self else { return }
            if let dominantFrequency = self.fftAnalyzer.analyze(buffer: buffer) {
                DispatchQueue.main.async {
                    self.pitchCompareModel.updateDetectedFrequency(dominantFrequency)
                }
            }
        }

        // Ensure the audio session is configured
        audioSessionManager.configureAudioSession()
    }

    func stopCapture() {
        // Stop the AudioSessionManager from capturing
        AudioSessionManager.shared.audioBufferCallback = nil
        AudioSessionManager.shared.stopAudioSession()
    }
}
