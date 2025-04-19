//
//  ExerciseBridgeOctaveStepper.swift
//  PitchPerfect
//
//  Created by Mark Hall on 4/19/25.
//
import Foundation

class ExerciseBridgeOctaveStepper: Exercise {
    private var steppingNotes: [(String, Float)] = []

    override var exerciseName: String {
        return "Bridge Octave Stepper"
    }

    private var noteIndex: Int = 0

    override init() {
        super.init()
    }

    override func getUsersRange() {
        super.getUsersRange()
        sortNotesByFrequency()
    }

    func sortNotesByFrequency() {
        exerciseNoteFrequencies.sort { $0.1 < $1.1 }
    }

    override func startExercise() {
        super.startExercise()
        generateSteppingNotes()
    }

    override func reset() {
        print("EBOS reset ,\(currentIndex)")
        currentIndex = 0
    }

    func generateSteppingNotes() {
        steppingNotes.removeAll()

        guard let user = userData else {
            print("❌ No user data available.")
            return
        }

        let bridgeNote = user.advancedSettings.midBridge

        guard !bridgeNote.isEmpty else {
            print("❌ No midBridge note set.")
            return
        }

        guard let bridgeIndex = exerciseNoteFrequencies.firstIndex(where: { $0.0 == bridgeNote }) else {
            print("❌ midBridge note \(bridgeNote) not found in range.")
            return
        }

        let startIndex = bridgeIndex - 7      // A seventh below midBridge
        let endIndex = bridgeIndex            // Base ends *at* midBridge
        let octaveInterval = 12               // One octave = 12 semitones

        for baseIndex in startIndex...endIndex {
            guard baseIndex >= 0,
                  baseIndex + octaveInterval < exerciseNoteFrequencies.count else {
                continue
            }

            let base = exerciseNoteFrequencies[baseIndex]
            let octaveUp = exerciseNoteFrequencies[baseIndex + octaveInterval]

            // Ensure octave is within user's max range
            if octaveUp.1 <= user.highestFrequency {
                steppingNotes.append(base)
                steppingNotes.append(octaveUp)
                steppingNotes.append(base)
            }
        }

        print("🎯 Bridge Octave Stepper built \(steppingNotes.count) notes")
    }

    override func nextNote() -> ((note: String, frequency: Float)?, isLast: Bool) {
        print("EBOS currentIndex: \(currentIndex)")
        print("EBOS steppingNotes.count: \(steppingNotes.count)")

        if currentIndex >= steppingNotes.count {
            currentIndex = 0
        }

        guard !steppingNotes.isEmpty else {
            return (nil, false)
        }

        let next = steppingNotes[currentIndex]
        currentIndex += 1
        let isLast = (currentIndex == steppingNotes.count)
        print("EBOS isLast: \(isLast)")

        return (next, isLast)
    }

    public override func getDescription() -> String {
        return description
    }

    override var description: String {
        return """
        This exercise begins a seventh below your mid-bridge note and climbs upward, step by step,
        to the bridge. Each step involves jumping an octave above and returning, helping smooth out
        register transitions while maintaining range safety.
        """
    }
}
