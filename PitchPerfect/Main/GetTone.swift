//
//  GetTone.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//

import AVFoundation
import Accelerate

class GetTone {
    private let audioEngine = AVAudioEngine()
    private let fftAnalyzer: FFTAnalyzer

    init(model: PitchCompareModel) {
        self.fftAnalyzer = FFTAnalyzer(model: model)
    }

    func startAudioCapture() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            // Convert buffer to Float samples
            guard let floatChannelData = buffer.floatChannelData else { return }
            let frameLength = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))

            // Pass samples to FFTAnalyzer
            self.fftAnalyzer.process(buffer: buffer)
        }

        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }

    func stopAudioCapture() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}
