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

    // ✅ Singleton instance


    // ✅ Private init prevents external instantiation
    private init() {
    }

    private var fftSize: Int = 65536  // ✅ Default to max resolution for low frequencies
    private let sampleRate : Float = Float(PitchCompareModel.shared.detectedSampleRate)





    
    func analyze(buffer: AVAudioPCMBuffer) -> Float? {
         guard let floatChannelData = buffer.floatChannelData else {
                print("No channel data available in buffer.")
                return nil
            }

            // ✅ Select FFT size dynamically based on `generatedFrequency`
            let generatedFrequency = pitchCompareModel.generatedFrequency

            if generatedFrequency < 500 {
                fftSize = 65536  // High resolution for low frequencies
            } else if generatedFrequency < 1700 {
                fftSize = 32768  // Medium resolution
            } else {
                fftSize = 16384  // Fast response for high frequencies
            }
         // ✅ Ensure sample count matches `fftSize`
            var samples = [Float](repeating: 0.0, count: fftSize)
            let frameLength = min(Int(buffer.frameLength), fftSize)  // Prevent buffer overflow
            samples.replaceSubrange(0..<frameLength, with: UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))

            let sampleCount = fftSize  // ✅ Explicitly set sampleCount

            let log2n = vDSP_Length(log2(Float(sampleCount)))
         // guard let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2)) else {
         //     print("Failed to create FFT setup")
         //     return nil
         // }
        if vDSP_create_fftsetup(log2n, Int32(kFFTRadix2)) == nil {
            print("Failed to create FFT setup")
            return nil
        }
        
        // Extract float channel data
       // guard let floatChannelData = buffer.floatChannelData else {
       //     print("No channel data available in buffer.")
       //     return nil
       // }
        if  buffer.floatChannelData == nil {
            print("No channel data available in buffer.")
            return nil
        }

        
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

                // ✅ Find the peak index
                if let peakIndex = magnitudes.firstIndex(of: magnitudes.max() ?? 0) {
                    
                    // ✅ Apply Parabolic Interpolation & Clamping
                    let refinedFrequency = interpolateAndClampFrequency(
                        peakIndex: peakIndex,
                        magnitudes: magnitudes,
                        referenceFrequency: self.pitchCompareModel.generatedFrequency
                    )
                    // ✅ Add this section for feedback:
                      let pitchErrorCents = 1200 * log2(refinedFrequency / referenceFrequency)
                      AudioFeedback.shared.playFeedbackTone(for: pitchErrorCents)
                    
                    // ✅ Update detected frequency
                    print("🎯 Refined dominantFrequency: \(refinedFrequency)")
                    self.pitchCompareModel.updateDetectedFrequency(refinedFrequency)
                    
                    dominantFrequency = refinedFrequency
                }
            }
        }

        vDSP_destroy_fftsetup(fftSetup)
        return dominantFrequency
    }
    
    private func interpolateAndClampFrequency(peakIndex: Int, magnitudes: [Float], referenceFrequency: Float) -> Float {
        if peakIndex <= 0 || peakIndex >= magnitudes.count - 1 { return referenceFrequency }

        let alpha = magnitudes[peakIndex - 1]
        let beta = magnitudes[peakIndex]
        let gamma = magnitudes[peakIndex + 1]

        // ✅ Parabolic interpolation formula
        let binOffset = 0.5 * (alpha - gamma) / (alpha - 2 * beta + gamma)
        let frequencyResolution = sampleRate / Float(fftSize)
        let detectedFrequency = (Float(peakIndex) + binOffset) * frequencyResolution

        // ✅ Compute threshold in Hz
        let centsThreshold: Float = (referenceFrequency < 500) ? 15.0 : 5.0
        let thresholdHz = referenceFrequency * (pow(2.0, centsThreshold / 1200.0) - 1.0)

        print("🔍 Raw Detected Frequency: \(detectedFrequency) Hz")
        print("🔹 Clamping Threshold: ±\(thresholdHz) Hz (±\(centsThreshold) cents)")
        print("🔹 Reference Frequency: \(referenceFrequency) Hz")

        // ✅ Clamp detected frequency if within threshold
        if abs(detectedFrequency - referenceFrequency) <= thresholdHz {
            print("✅ Clamping Applied → \(referenceFrequency) Hz")
            return referenceFrequency  // 🔹 Lock it to expected frequency
        } else {
            print("🎯 Keeping Interpolated Frequency → \(detectedFrequency) Hz")
            return detectedFrequency  // 🔹 Use refined detected frequency
        }
    }
}
