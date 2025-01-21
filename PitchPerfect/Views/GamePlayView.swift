//
//  GamePlayView.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//
import SwiftUI

struct GameplayView: View {
    let selectedUser: UserData
    let onStop: () -> Void

    @State private var currentNote: String = ""
    @State private var currentTone: String = ""
    @State private var matchResult: String = "" // Result of pitch comparison

    var body: some View {
        VStack {
            Text("Playing for \(selectedUser.userName)")
                .font(.title2)
                .padding()

            Text("Current Note: \(currentNote)")
                .font(.headline)
                .padding()

            Text("Match Result: \(matchResult)")
                .font(.headline)
                .foregroundColor(matchResult == "Matched" ? .green : .red)
                .padding()

            Spacer()

            Button(action: onStop) {
                Text("Stop Gameplay")
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear(perform: runGameplayLoop)
    }

    private func runGameplayLoop() {
        DispatchQueue.global(qos: .userInitiated).async {
            while true {
                guard !Task.isCancelled else { break }

                // Step 1: Select a note
                currentNote = selectNote()

                // Step 2: Play the tone
                playTone(for: currentNote)

                // Step 3: Retrieve the sung tone
                currentTone = getSungTone()

                // Step 4: Compare pitches
                matchResult = comparePitches(target: currentNote, sung: currentTone)

                // Step 5: Store attempt data (future implementation)
                storeAttemptData(note: currentNote, result: matchResult)

                // Simulate a delay (e.g., waiting for user input)
                Thread.sleep(forTimeInterval: 2.0)
            }
        }
    }

    // Placeholder methods for gameplay steps
    private func selectNote() -> String {
        return ["C", "D", "E", "F", "G", "A", "B"].randomElement() ?? "C"
    }

    private func playTone(for note: String) {
        print("Playing tone for \(note)")
    }

    private func getSungTone() -> String {
        // Simulated sung tone (placeholder)
        return ["C", "D", "E", "F", "G", "A", "B"].randomElement() ?? "C"
    }

    private func comparePitches(target: String, sung: String) -> String {
        return target == sung ? "Matched" : "Not Matched"
    }

    private func storeAttemptData(note: String, result: String) {
        print("Storing attempt data for note \(note): \(result)")
    }
}
