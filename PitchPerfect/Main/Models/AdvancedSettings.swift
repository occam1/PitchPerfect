//
//  AdvancedSettings.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/2/25.
//
import Foundation
class AdvancedSettings: Codable, ObservableObject {
    @Published var lowestNote: String {
        didSet { UserData.shared?.save() }
    }
    
    @Published var midBridge: String {
        didSet { UserData.shared?.save() }
    }
    
    @Published var highestNote: String {
        didSet { UserData.shared?.save() }
    }
    
    @Published var selectedKey: String {
        didSet { UserData.shared?.save() }
    }

    init(lowestNote: String, midBridge: String, highestNote: String, selectedKey: String) {
        self.lowestNote = lowestNote
        self.midBridge = midBridge
        self.highestNote = highestNote
        self.selectedKey = selectedKey
    }

    // ✅ Ensure all properties are included in encoding/decoding
    enum CodingKeys: String, CodingKey {
        case lowestNote, midBridge, highestNote, selectedKey
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lowestNote = try container.decode(String.self, forKey: .lowestNote)
        self.highestNote = try container.decode(String.self, forKey: .highestNote)
        self.selectedKey = try container.decode(String.self, forKey: .selectedKey)
        self.midBridge = try container.decodeIfPresent(String.self, forKey: .midBridge) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lowestNote, forKey: .lowestNote)
        try container.encode(midBridge, forKey: .midBridge)
        try container.encode(highestNote, forKey: .highestNote)
        try container.encode(selectedKey, forKey: .selectedKey)
    }
}
