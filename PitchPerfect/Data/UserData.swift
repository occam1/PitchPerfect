//
//  UserData.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//
import Foundation

struct UserData: Codable {
    let userName: String
    var attempts: [Attempt]
    var advancedSettings: AdvancedSettings
}

struct Attempt: Codable {
    let noteName: String
    let isSharp: Bool
    let isFlat: Bool
    let date: Date
}

struct AdvancedSettings: Codable {
    var lowestNote: String
    var highestNote: String
    var selectedKey: String
}
