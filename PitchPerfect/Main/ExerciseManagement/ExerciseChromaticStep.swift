//
//  ExerciseChromaticStep.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/27/25.
//
class ExerciseChromaticStep: Exercise {
    let name = "Chromatic Steps"
    private var notes: [String] = [] // Full range of notes
    private var currentIndex: Int = 0

    init() {
        notes = generateChromaticRange(from: "3C", to: "5D")
        print("notes, \(AppDataManager.keys)")
        print("mapped notes , \(notes)")
    }
    
    func nextNote(currentNote: String?) -> String? {
        guard currentIndex < notes.count else { return nil }
        let next = notes[currentIndex]
        currentIndex += 1
        return next
    }

    func reset() {
        currentIndex = 0
    }

    private func generateChromaticRange(from start: String, to end: String) -> [String] {
        // Logic to generate chromatic notes from start to end
        // Example: ["C3", "C#3", "D3", ... "D5"]
        guard let startFrequency = AppDataManager.noteFrequencies[start],
              let endFrequency = AppDataManager.noteFrequencies[end] else {
            print("Invalid start or end note provided: \(start), \(end)")
            return [] // Return an empty array if unwrapping fails
        }
        let filteredNoteLabels = AppDataManager.noteFrequencies
                .filter { _, frequency in
                    frequency >= startFrequency && frequency <= endFrequency // Filter by frequency
                }
                .sorted { $0.value < $1.value } // Sort by frequency
                .map { $0.key } // Extract the note labels
            return filteredNoteLabels                                // Extract only the keys
         
    }
}
