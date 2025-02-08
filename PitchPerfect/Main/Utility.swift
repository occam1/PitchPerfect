//
//  Utility.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/27/25.
//

class Utility {
    public static let shared = Utility()
    
    
   func convertToNoteOctave(from octaveNote: String) -> String {
        // Split the string into the octave and note components
        let octave = String(octaveNote.prefix(1))    // First character is the octave
        let note = String(octaveNote.dropFirst(1))   // Remaining part is the note
        return "\(note)\(octave)"                   // Combine note and octave in desired format
    }
    
   func convertToOctaveNote(_ str: String) -> String {
            if str.count == 2 {
                let lastChar = str.last!
                let remainingChar = str.first!
                return "\(lastChar)\(remainingChar)"
            } else if str.count == 3 {
                let lastChar = str.last!
                let remainingChars = str.dropLast()
                return "\(lastChar)\(remainingChars)"
            } else {
                return str // This case should never happen since you only allow 2 or 3 characters
            }
        }


    
    
}
