//
//  WaveformView.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//
import SwiftUI

struct PitchComparisonView: View {
    @ObservedObject var model = PitchCompareModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Static line for the generated frequency
                let mappedHeight =  mapFrequencyToYPosition(
                    frequency: model.generatedFrequency,
                    referenceFrequency: model.generatedFrequency,
                    height: 200.0,
                    label: model.currentNoteLabel
                )
                LineView(yPosition: mappedHeight, color: .green)
                    .frame(width: geometry.size.width, height: 200)
                // Light gray box representing the 20-cent tolerance
                Rectangle()
                    .fill(Color.gray.opacity(0.2)) // Light gray with transparency
                    .frame(width: geometry.size.width, height: 40) // Box is 40 points tall
                    .offset(y: mappedHeight - 100) // Center the box on the reference line
                Rectangle()
                    .fill(Color.gray.opacity(0.2)) // Light gray with transparency
                    .frame(width: geometry.size.width, height: 20) // Box is 40 points tall
                    .offset(y: mappedHeight - 100) // Center the box on the reference line
                Rectangle()
                    .fill(Color.gray.opacity(0.2)) // Light gray with transparency
                    .frame(width: geometry.size.width, height: 10) // Box is 40 points tall
                    .offset(y: mappedHeight - 100) // Center the box on the reference line
                Text(model.currentNoteLabel)
                                       .font(.caption)
                                       .foregroundColor(.red)
                                       .offset(x: -20)// Adjust as needed
                

                             
                // Detected frequency lines
                ForEach(Array(model.detectedFrequencies.enumerated()), id: \.0) { index, frequency in
                    let offset = CGFloat(index) * (geometry.size.width / CGFloat(model.maxVisibleLines))
                    let mappedHeight =  mapFrequencyToYPosition(
                        frequency: frequency,
                        referenceFrequency: model.generatedFrequency,
                        height: 200.0,
                        label: model.currentNoteLabel
                    )
                    LineView(yPosition: mappedHeight, color: .blue)
                        .frame(width: geometry.size.width / CGFloat(model.maxVisibleLines), height: 200.0)
                        .offset(x: offset)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            .border(Color.gray)
        }
        .padding()
    }
    
    // Map a frequency to a y-position relative to the generated frequency
    private func mapFrequencyToYPosition(frequency: Float, referenceFrequency: Float, height: CGFloat, label: String) -> CGFloat {
        guard frequency > 0 else { return -1 } // Render off-screen for invalid frequencies
        if PitchPerfectApp.doDebug {
            print("mapping freq: ,\(frequency) label, \(label)")
        }
        // Calculate cents difference
        let centsDifference = 1200 * log2(frequency / referenceFrequency)
        
        // Clip to ±100 cents
        let clippedCents = max(-100, min(centsDifference, 100))
        
        
        // Map cents difference directly to height
        if PitchPerfectApp.doDebug {
            print("mappedHeight: ,\(height * CGFloat((100 - clippedCents) / 200))")
        }
            return height * CGFloat((100 - clippedCents) / 200)
    }
}

struct LineView: View {
    let yPosition: CGFloat
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let y = yPosition // Directly use pre-mapped position

                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: width, y: y))
            }
            .stroke(color, lineWidth: 2)
        }
    }
}


