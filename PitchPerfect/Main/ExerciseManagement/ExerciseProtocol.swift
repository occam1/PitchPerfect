//
//  Untitled.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/27/25.
//
protocol Exercise {
    var name: String { get } // Display name of the exercise
    func nextNote(currentNote: String?) -> String? // Determines the next note in the exercise
    func reset() // Resets the exercise to its starting state
}
