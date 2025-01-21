//
//  AppDataManager.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//
import SwiftUI
import Foundation

class AppDataManager {
    // Static properties to hold data
    public static var keys: [String] = []
    public static var keyNotes: [String: [String]] = [:]

    // Static initializer to load data
    static func initialize() {
        self.keys = loadKeysFromJSON()
        self.keyNotes = loadKeyNotesFromJSON()
    }

    // Static function to access just the keys
    static func getKeys() -> [String] {
        return keys
    }

    // Static function to access keys with their notes
    static func getKeyNotes() -> [String: [String]] {
        return keyNotes
    }

    // Private static function to load just the keys
    public static func loadKeysFromJSON() -> [String] {
        guard let fileURL = Bundle.main.url(forResource: "keys", withExtension: "json") else {
            print("keys.json not found in bundle.")
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let keysData = try JSONDecoder().decode(KeysData.self, from: data)
            return keysData.keys.sorted() // Sort keys alphabetically
        } catch {
            print("Error loading keys.json: \(error)")
            return []
        }
    }

    // Private static function to load keys with their corresponding notes
    public static func loadKeyNotesFromJSON() -> [String: [String]] {
        guard let fileURL = Bundle.main.url(forResource: "keyNotes", withExtension: "json") else {
            print("keyNotes.json not found in bundle.")
            return [:]
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let keyNotesData = try JSONDecoder().decode(KeyNotesData.self, from: data)
            return keyNotesData.keyNotes
        } catch {
            print("Error loading keyNotess.json: \(error)")
            return [:]
        }
    }
}

// Struct for keys only
struct KeysData: Codable {
    let keys: [String]
}

// Struct for keys and their notes
struct KeyNotesData: Codable {
    let keyNotes: [String: [String]]
}
