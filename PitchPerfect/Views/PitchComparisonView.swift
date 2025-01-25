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
             
                // Solid line for the generated frequency
                 LineView(yPosition: model.generatedToneY, color: .green)
                     .frame(width: geometry.size.width, height: geometry.size.height)
                     //.offset(y: -50)
               
                ForEach(Array(model.lines.enumerated()), id: \.1.id) { index, line in
                    let offset = CGFloat(index) * (geometry.size.width / CGFloat(model.maxVisibleLines))
                    // Add a Text view to indicate rendering
               
                  
                    LineView(yPosition: line.yPosition, color: .blue)
                        .frame(width: geometry.size.width / CGFloat(model.maxVisibleLines), height: geometry.size.height)
                        .offset(x: offset)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .border(Color.gray)
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
                let y = -50 + height - (yPosition * height) // Map y-position to view height

                // Draw a horizontal line
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
