//
//  WaveformView.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//
import SwiftUI

struct PitchComparisonView: View {
    @ObservedObject var model: PitchCompareModel // Observable model for dynamic updates

    var body: some View {
        VStack {
            HStack {
                Text(model.currentNoteLabel) // Label for the note name
                    .font(.headline)
                    .frame(width: 50, alignment: .trailing)

                ZStack {
                    // Generated tone (static line)
                    LineView(yPosition: model.generatedToneY, color: .blue)

                    // Sung tone (dynamic line)
                    if let sungToneY = model.sungToneY {
                        LineView(yPosition: sungToneY, color: .red)
                    }
                }
                .frame(height: 100) // Adjust height as needed
                .border(Color.gray.opacity(0.5)) // Optional border
            }
        }
        .padding()
    }
}

struct LineView: View {
    let yPosition: CGFloat
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let y = height - (yPosition * height) // Map y-position to view height

                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: width, y: y))
            }
            .stroke(color, lineWidth: 2)
        }
    }
}

struct PitchComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        PitchComparisonView(model: PitchCompareModel())
            .frame(width: 300, height: 120)
    }
}
