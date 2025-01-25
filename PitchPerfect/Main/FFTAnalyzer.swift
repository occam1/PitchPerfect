//
//  FFTAnalyzer.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//

import Accelerate
import AVFoundation

class FFTAnalyzer {
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

        // Allocate memory for real and imaginary parts
        var real = samples
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
                //print("magnitude ,\(magnitudes)")
                // Find the dominant frequency
                if let maxIndex = magnitudes.firstIndex(of: magnitudes.max() ?? 0) {
                    let samplingRate: Float = 48000.0 // Example sampling rate
                    let frequencyResolution = samplingRate / Float(sampleCount)
                    dominantFrequency = Float(maxIndex) * frequencyResolution
                    print("dominantFrequency , \(dominantFrequency)")
                }
            }
        }

        vDSP_destroy_fftsetup(fftSetup)
        return dominantFrequency
    }
}
