//
//  FFTAnalyzer.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//
import Combine
import Accelerate
import AVFoundation

class FFTAnalyzer {
    static let shared = FFTAnalyzer()
    let pitchCompareModel = PitchCompareModel.shared

    private var fftSize: Int = 65536
    private let sampleRate: Float
    private let log2n: vDSP_Length
    private let fftSetup: FFTSetup? // ✅ Store FFT Setup as a class variable

    // ✅ Initialize once and reuse
    private init() {
        self.sampleRate = Float(PitchCompareModel.shared.detectedSampleRate)
        self.log2n = vDSP_Length(log2(Float(fftSize)))
        self.fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2)) // ✅ Create FFT setup once

        if fftSetup == nil {
            print("❌ Failed to create FFT setup")
        } else {
            print("✅ FFT Setup Created")
        }
    }

    func analyze(buffer: AVAudioPCMBuffer) -> Float? {
        guard let fftSetup = fftSetup else {
            print("❌ FFT Setup is nil")
            return nil
        }

        guard let floatChannelData = buffer.floatChannelData else {
            print("No channel data available in buffer.")
            return nil
        }

        let generatedFrequency = pitchCompareModel.generatedFrequency
        if generatedFrequency < 500 {
            fftSize = 65536
        } else if generatedFrequency < 1700 {
            fftSize = 32768
        } else {
            fftSize = 16384
        }

        var samples = [Float](repeating: 0.0, count: fftSize)
        let frameLength = min(Int(buffer.frameLength), fftSize)
        samples.replaceSubrange(0..<frameLength, with: UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))

        let sampleCount = fftSize
        var window = [Float](repeating: 0.0, count: sampleCount)
        vDSP_hann_window(&window, vDSP_Length(sampleCount), Int32(vDSP_HANN_NORM))

        var windowedSamples = [Float](repeating: 0.0, count: sampleCount)
        vDSP_vmul(samples, 1, window, 1, &windowedSamples, 1, vDSP_Length(sampleCount))

        var real = windowedSamples
        var imaginary = [Float](repeating: 0.0, count: sampleCount)
        var dominantFrequency: Float? = nil

        real.withUnsafeMutableBufferPointer { realPtr in
            imaginary.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                vDSP_fft_zip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))

                var magnitudes = [Float](repeating: 0.0, count: sampleCount / 2)
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(sampleCount / 2))

                let samplingRate: Float = 48000.0
                let frequencyResolution = samplingRate / Float(sampleCount)
                let referenceFrequency = self.pitchCompareModel.generatedFrequency

                let minFrequency = referenceFrequency / pow(2.0, 1.0 / 12.0)
                let maxFrequency = referenceFrequency * pow(2.0, 1.0 / 12.0)

                let minIndex = max(0, Int(minFrequency / frequencyResolution))
                let maxIndex = min(magnitudes.count, Int(maxFrequency / frequencyResolution))

                for i in 0..<magnitudes.count {
                    if i < minIndex || i > maxIndex {
                        magnitudes[i] = 0.0
                    }
                }

                if let peakIndex = magnitudes.firstIndex(of: magnitudes.max() ?? 0) {
                    let refinedFrequency = interpolateAndClampFrequency(
                        peakIndex: peakIndex,
                        magnitudes: magnitudes,
                        referenceFrequency: self.pitchCompareModel.generatedFrequency
                    )

                    print("🎯 Refined dominantFrequency: \(refinedFrequency)")
                    self.pitchCompareModel.updateDetectedFrequency(refinedFrequency)

                    // ✅ Restore pitch feedback
                    let pitchErrorCents = 1200 * log2(refinedFrequency / referenceFrequency)
                    DispatchQueue.main.async {
                        AudioFeedback.shared.playFeedbackTone(for: pitchErrorCents)
                    }
                    print("🔊 Playing feedback tone for pitch error: \(pitchErrorCents) cents")

                    dominantFrequency = refinedFrequency
                }
            }
        }

        return dominantFrequency
    }

    deinit {
        if let fftSetup = fftSetup {
            vDSP_destroy_fftsetup(fftSetup)
            print("❌ FFT Setup Destroyed")
        }
    }

    private func interpolateAndClampFrequency(peakIndex: Int, magnitudes: [Float], referenceFrequency: Float) -> Float {
        if peakIndex <= 0 || peakIndex >= magnitudes.count - 1 { return referenceFrequency }

        let alpha = magnitudes[peakIndex - 1]
        let beta = magnitudes[peakIndex]
        let gamma = magnitudes[peakIndex + 1]

        let binOffset = 0.5 * (alpha - gamma) / (alpha - 2 * beta + gamma)
        let frequencyResolution = sampleRate / Float(fftSize)
        let detectedFrequency = (Float(peakIndex) + binOffset) * frequencyResolution

        let centsThreshold: Float = (referenceFrequency < 500) ? 15.0 : 5.0
        let thresholdHz = referenceFrequency * (pow(2.0, centsThreshold / 1200.0) - 1.0)

        print("🔍 Raw Detected Frequency: \(detectedFrequency) Hz")
        print("🔹 Clamping Threshold: ±\(thresholdHz) Hz (±\(centsThreshold) cents)")
        print("🔹 Reference Frequency: \(referenceFrequency) Hz")

        if abs(detectedFrequency - referenceFrequency) <= thresholdHz {
            print("✅ Clamping Applied → \(referenceFrequency) Hz")
            return referenceFrequency
        } else {
            print("🎯 Keeping Interpolated Frequency → \(detectedFrequency) Hz")
            return detectedFrequency
        }
    }
}
