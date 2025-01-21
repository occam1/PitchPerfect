//
//  PlayTone.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//

import AVFoundation

func playTone(frequency: Double, duration: TimeInterval) {
    let audioEngine = AVAudioEngine()
    let oscillatorNode = AVAudioSourceNode { _, _, frameCount, audioBufferList in
        let audioBuffer = UnsafeMutableAudioBufferListPointer(audioBufferList)
        let sampleRate = 44100.0
        let phaseIncrement = 2.0 * .pi * frequency / sampleRate
        var currentPhase: Float = 0

        for frame in 0..<Int(frameCount) {
            let value = sin(currentPhase)
            currentPhase += Float(phaseIncrement)
            if currentPhase >= 2.0 * .pi { currentPhase -= 2.0 * .pi }

            for buffer in audioBuffer {
                buffer.mData?.assumingMemoryBound(to: Float.self)[frame] = value
            }
        }

        return noErr
    }

    let mainMixer = audioEngine.mainMixerNode
    audioEngine.attach(oscillatorNode)
    audioEngine.connect(oscillatorNode, to: mainMixer, format: mainMixer.outputFormat(forBus: 0))

    do {
        try audioEngine.start()
        DispatchQueue.global().asyncAfter(deadline: .now() + duration) {
            audioEngine.stop()
        }
    } catch {
        print("Error starting audio engine: \(error)")
    }
}
