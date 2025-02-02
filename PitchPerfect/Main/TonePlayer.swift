//
//  PlayTone.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//


import AVFoundation

class TonePlayer {
    static let shared = TonePlayer() // Define the singleton instance
    private let pitchCompareModel = PitchCompareModel.shared
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var sampleRate : Double
    private var audioFormat : AVAudioFormat
   
    
    private init() {
        self.sampleRate = pitchCompareModel.detectedSampleRate
        self.audioFormat = AVAudioFormat(standardFormatWithSampleRate: self.sampleRate, channels: 1)!
    }

    
    func startPlayingTone(frequency: Float, duration: TimeInterval = 2.0) {
        
        // Calculate the buffer duration
        let bufferDuration = min(duration, 2.0) // Generate up to 2 seconds at a time
        let buffer = generateToneBuffer(frequency: frequency, duration: bufferDuration)

        if PitchPerfectApp.doDebug {
            print("Started playing tone for \(duration) seconds.")
        }

        // Attach and connect the playerNode
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFormat)

        do {
            // Start the audio engine
            try audioEngine.start()
        } catch {
            print("AudioEngine failed to start: \(error)")
            return
        }

        // Schedule the buffer repeatedly to honor the duration
        var timePlayed: TimeInterval = 0.0
        while timePlayed < duration {
            let playTime = min(bufferDuration, duration - timePlayed)
            scheduleBuffer(buffer: buffer, playTime: playTime)
            timePlayed += playTime
        }

        // Stop playback and audio engine
        playerNode.stop()
        audioEngine.stop()

        if PitchPerfectApp.doDebug {
            print("Stopped playing tone.")
        }
        
    }
    /// ✅ **Generates a tone that glides between two frequencies over a specified duration**
    func playGlidingTone(from startFreq: Float, to endFreq: Float, duration: TimeInterval) {
        let frameCount = AVAudioFrameCount(sampleRate * duration * 2) // Up + Down
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)!

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let audioBuffer = buffer.floatChannelData![0]

        let halfFrameCount = Int(frameCount / 2) // Precompute to avoid division in loop
        let invHalfFrameCount = 1.0 / Float(halfFrameCount) // Precompute inverse for multiplication
        let sampleRateFloat = Float(sampleRate) // Avoid repeated type conversion

        for i in 0..<Int(frameCount) {
            let frameIndex = Float(i) // Explicitly declare to avoid implicit conversions
            let isAscending = i < halfFrameCount
            let progress = Float(i % halfFrameCount) * invHalfFrameCount // Normalize 0 → 1

            let currentFreq: Float = isAscending
                ? startFreq + (endFreq - startFreq) * progress  // Glide Up
                : endFreq - (endFreq - startFreq) * progress  // Glide Down

            let phase: Float = (2.0 * .pi * currentFreq * frameIndex) / sampleRateFloat
            audioBuffer[i] = sin(phase) // Generate the sample
        }

        playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        playerNode.play()
    }

    private func scheduleBuffer(buffer: AVAudioPCMBuffer, playTime: TimeInterval) {
        playerNode.scheduleBuffer(buffer, at: nil) {
            if PitchPerfectApp.doDebug {
                print("Finished playing \(playTime) seconds of tone.")
            }
        }
        playerNode.play()

        // Delay to ensure the buffer finishes playing
        Thread.sleep(forTimeInterval: playTime)
    }

    private func generateToneBuffer(frequency: Float, duration: TimeInterval) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(audioFormat.sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let samples = buffer.floatChannelData![0]
        let sampleRate = Float(audioFormat.sampleRate)
        let frequencyFloat = Float(frequency)

        for frame in 0..<Int(frameCount) {
            let sample = sin(2.0 * .pi * frequencyFloat * Float(frame) / sampleRate)
            samples[frame] = sample
        }

        return buffer
    }
    func stopPlaying() {
        playerNode.stop()
        audioEngine.stop()
    }
}










/*
class TonePlayer {
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!

    func startPlayingTone(frequency: Float, duration: TimeInterval = 2.0) {
        let buffer = generateToneBuffer(frequency: frequency, duration: duration)
        print("Started playing tone.")
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFormat)

        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine failed to start: \(error)")
            return
        }

        playerNode.scheduleBuffer(buffer, at: nil) {
            print("Finished playing tone.")
        }

        playerNode.play()
    }

    private func generateToneBuffer(frequency: Float, duration: TimeInterval) -> AVAudioPCMBuffer {
        let frameCount = UInt32(audioFormat.sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let thetaIncrement = 2.0 * Double.pi * Double(frequency) / audioFormat.sampleRate
        var theta = 0.0

        let channels = buffer.floatChannelData!
        let channel = channels[0]

        for frame in 0..<Int(frameCount) {
            channel[frame] = Float(sin(theta))
            theta += thetaIncrement
            if theta > 2.0 * Double.pi {
                theta -= 2.0 * Double.pi
            }
        }

        return buffer
    }

    func stopPlaying() {
        playerNode.stop()
        audioEngine.stop()
    }
}
*/
