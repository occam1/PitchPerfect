//
//  AudioFeedback.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/2/25.
//
import AVFoundation

class AudioFeedback {
    static let shared = AudioFeedback()
   let pitchCompareModel = PitchCompareModel.shared
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    var sampleRate: Double = 0.0

    private init() {
        setupAudioEngine()
        sampleRate =  pitchCompareModel.detectedSampleRate
    }

    private func setupAudioEngine() {
        let sampleRate = PitchCompareModel.shared.detectedSampleRate  // Ensure consistent sample rate
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!  // Ensure mono output

        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFormat)

        do {
            try audioEngine.start()
            print("✅ Audio Engine started with sample rate: \(sampleRate)")
        } catch {
            print("❌ Failed to start Audio Engine: \(error)")
        }
    }

    /// ✅ **Plays a short feedback tone indicating sharpness or flatness**
    func playFeedbackTone(for error: Float) {
        guard abs(error) > 5.0 else { return } // Ignore very small deviations
       
        let baseFreq: Float = 400.0  // Neutral reference tone
        let feedbackFreq = baseFreq * pow(2.0, error / 1200.0) // Adjust by cents

        let buffer = generateToneBuffer(frequency: feedbackFreq, duration: 0.2)
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
         playerNode.play()
    }

    private func generateToneBuffer(frequency: Float, duration: TimeInterval) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(Float(sampleRate) * Float(duration))
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let audioBuffer = buffer.floatChannelData![0]

        for i in 0..<Int(frameCount) {
            let phase = 2.0 * .pi * frequency * Float(i) / Float(sampleRate)
            
            audioBuffer[i] = 0.1 * sin(phase) // Reduce volume by 90%
        }
        return buffer
    }
}
