//
//  FFTAnalyzer.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//

import Accelerate
import AVFoundation

class FFTAnalyzer {
    let pitchCompareModel = PitchCompareModel.shared

    func analyze(buffer: AVAudioPCMBuffer) -> Float? {
        // Extract float channel data
        guard let floatChannelData = buffer.floatChannelData else {
            print("No channel data available in buffer.")
            return nil
        }

        let frameLength = Int(buffer.frameLength)
        let samples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))

        let sampleCount = samples.count
        let log2n = vDSP_Length(log2(Float(sampleCount)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2)) else {
            print("Failed to create FFT setup")
            return nil
        }

        // ✅ Generate Hann Window
        var window = [Float](repeating: 0.0, count: sampleCount)
        vDSP_hann_window(&window, vDSP_Length(sampleCount), Int32(vDSP_HANN_NORM))

        // ✅ Apply Hann Window
        var windowedSamples = [Float](repeating: 0.0, count: sampleCount)
        vDSP_vmul(samples, 1, window, 1, &windowedSamples, 1, vDSP_Length(sampleCount))

        // Allocate memory for real and imaginary parts
        var real = windowedSamples  // ✅ Use the windowed samples
        var imaginary = [Float](repeating: 0.0, count: sampleCount)
        var dominantFrequency: Float? = nil

        real.withUnsafeMutableBufferPointer { realPtr in
            imaginary.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)

                // Perform FFT
                vDSP_fft_zip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))

                // Calculate magnitudes
                var magnitudes = [Float](repeating: 0.0, count: sampleCount / 2)
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(sampleCount / 2))

                // Frequency resolution and range calculation
                let samplingRate: Float = 48000.0 // Example sampling rate
                let frequencyResolution = samplingRate / Float(sampleCount)

                // Use generatedFrequency as the reference
                let referenceFrequency = self.pitchCompareModel.generatedFrequency

                // Calculate semitone range
                let minFrequency = referenceFrequency / pow(2.0, 1.0 / 12.0) // Semitone below
                let maxFrequency = referenceFrequency * pow(2.0, 1.0 / 12.0) // Semitone above

                // Ignore frequencies outside the range
                let minIndex = max(0, Int(minFrequency / frequencyResolution))
                let maxIndex = min(magnitudes.count, Int(maxFrequency / frequencyResolution))
                for i in 0..<magnitudes.count {
                    if i < minIndex || i > maxIndex {
                        magnitudes[i] = 0.0
                    }
                }

                // Find the dominant frequency
                if let maxIndex = magnitudes.firstIndex(of: magnitudes.max() ?? 0) {
                    dominantFrequency = Float(maxIndex) * frequencyResolution
                    if let unwrappedFrequency = dominantFrequency {
                        print("Filtered dominantFrequency: \(unwrappedFrequency)")
                        self.pitchCompareModel.updateDetectedFrequency(unwrappedFrequency)
                    }
                }
            }
        }

        vDSP_destroy_fftsetup(fftSetup)
        return dominantFrequency
    }
}
