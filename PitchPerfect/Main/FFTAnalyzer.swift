//
//  FFTAnalyzer.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//

import AVFoundation
import Accelerate

class FFTAnalyzer {
    private let pitchCompareModel: PitchCompareModel

    init(model: PitchCompareModel) {
        self.pitchCompareModel = model
    }

    func process(buffer: AVAudioPCMBuffer) {
        // Extract float channel data
        guard let floatChannelData = buffer.floatChannelData else {
            print("No channel data available in buffer.")
            return
        }

        let frameLength = Int(buffer.frameLength)
        let samples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))

        // Perform FFT analysis
        let dominantFrequency = performFFT(samples: samples)

        // Update the PitchCompareModel with the detected frequency
        PitchCompare.update(with: dominantFrequency, model: pitchCompareModel)
    }

    private func performFFT(samples: [Float]) -> Float {
        let sampleCount = samples.count
        let log2n = vDSP_Length(log2(Float(sampleCount)))
        var fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))

        var real = [Float](samples)
        var imaginary = [Float](repeating: 0.0, count: sampleCount)
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)

        vDSP_fft_zip(fftSetup!, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))

        // Calculate magnitudes
        var magnitudes = [Float](repeating: 0.0, count: sampleCount / 2)
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(sampleCount / 2))

        // Find the dominant frequency
        let maxIndex = magnitudes.firstIndex(of: magnitudes.max() ?? 0) ?? 0
        let samplingRate: Float = 44100.0 // Example sampling rate
        let frequencyResolution = samplingRate / Float(sampleCount)
        let dominantFrequency = Float(maxIndex) * frequencyResolution

        vDSP_destroy_fftsetup(fftSetup)

        return dominantFrequency
    }
}
