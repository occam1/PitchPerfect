//
//  GamePlay.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//
// determine what the next note will be based on the user specific advanced settings and their level
import Foundation

class GamePlay {
    init() {
        // Step 1: Configure the audio session
        Init.configureAudioSession()
        
        // Step 2: Load keys data
        let keys = AppDataManager.loadKeysFromJSON()
        
        // Step 3: Load key-notes data
        let keyNotes = AppDataManager.loadKeyNotesFromJSON()
        
        // Print to confirm the data is loaded (optional)
        print("Audio session configured.")
        print("Keys: \(keys)")
        print("Key Notes: \(keyNotes)")

        // Continue with the rest of the app logic...
    }
}
