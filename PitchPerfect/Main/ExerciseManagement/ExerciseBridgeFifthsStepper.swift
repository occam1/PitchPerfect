//
//  ExerciseBridgeFifthsStepper.swift
//  PitchPerfect
//
//  Created by Mark Hall on 4/19/25.
//
import Foundation

class ExerciseBridgeFifthsStepper: Exercise {
    private var steppingNotes: [(String, Float)] = []

    override var exerciseName: String {
        return "Bridge Fifths Stepper"
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
        print("EBFS reset ,\(currentIndex)")
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

        let startIndex = bridgeIndex - 5  // A fourth below bridge
        let endIndex = bridgeIndex        // End *at* bridge

        let fifthInterval = 7

        for baseIndex in startIndex...endIndex {
            guard baseIndex >= 0,
                  baseIndex + fifthInterval < exerciseNoteFrequencies.count else {
                continue
            }

            let base = exerciseNoteFrequencies[baseIndex]
            let fifth = exerciseNoteFrequencies[baseIndex + fifthInterval]

            steppingNotes.append(base)
            steppingNotes.append(fifth)
            steppingNotes.append(base)
        }

        print("🎯 Bridge Fifths Stepper built \(steppingNotes.count) notes")
    }

    override func nextNote() -> ((note: String, frequency: Float)?, isLast: Bool) {
        print("EBFS currentIndex: \(currentIndex)")
        print("EBFS steppingNotes.count: \(steppingNotes.count)")

        if currentIndex >= steppingNotes.count {
            currentIndex = 0
        }

        guard !steppingNotes.isEmpty else {
            return (nil, false)
        }

        let next = steppingNotes[currentIndex]
        currentIndex += 1
        let isLast = (currentIndex == steppingNotes.count)
        print("EBFS isLast: \(isLast)")

        return (next, isLast)
    }

    public override func getDescription() -> String {
        return description
    }

    override var description: String {
        return """
        This exercise begins a fourth below the user's mid-bridge note and works upward by semitone steps.
        For each step, it jumps up a fifth and returns, allowing the voice to cross the bridge temporarily
        and return to chest. The base note never exceeds the bridge.
        """
    }
}
