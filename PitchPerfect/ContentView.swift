import SwiftUI
struct ContentView: View {
    @ObservedObject private var pitchCompareModel = PitchCompareModel.shared

    var body: some View {
        VStack {
            // Pitch Comparison View
            PitchComparisonView()
                .padding()

            Spacer()

            // Automatic/Manual Toggle Button
            Button(action: toggleMode) {
                Text(pitchCompareModel.isAutomatic ? "Switch to Manual" : "Switch to Automatic")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(pitchCompareModel.isAutomatic ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            // Pause/Next/Resume Button
            Button(action: handlePauseNextResume) {
                Text(buttonLabelText())
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Spacer()
        }
        .navigationTitle("Pitch Practice")
    }

    // MARK: - Button Actions

    private func toggleMode() {
        pitchCompareModel.isAutomatic.toggle()
        pitchCompareModel.isPaused = false // Reset paused state when switching modes
    }

    private func handlePauseNextResume() {
        if pitchCompareModel.isAutomatic {
            pitchCompareModel.isPaused.toggle()
            if pitchCompareModel.isPaused {
                print("Playback paused")
                
            } else {
                print("Playback resumed")
            }
        } else {
            print("Next pitch")
            pitchCompareModel.isPaused = false
            // Manual mode logic to play the next pitch
        }
    }

    private func buttonLabelText() -> String {
        if pitchCompareModel.isAutomatic {
            return pitchCompareModel.isPaused ? "Resume" : "Pause"
        } else {
            return "Next"
        }
    }
}
