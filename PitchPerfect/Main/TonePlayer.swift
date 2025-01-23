//
//  PlayTone.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//


import AVFoundation

class TonePlayer {
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!

    func startPlayingTone(frequency: Double, duration: TimeInterval = 2.0) {
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

    private func generateToneBuffer(frequency: Double, duration: TimeInterval) -> AVAudioPCMBuffer {
        let frameCount = UInt32(audioFormat.sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let thetaIncrement = 2.0 * Double.pi * frequency / audioFormat.sampleRate
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
