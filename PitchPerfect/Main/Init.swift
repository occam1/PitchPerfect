//
//  Init.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/21/25.
//
import AVFoundation
class Init {
   public static func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Error configuring audio session: \(error)")
        }
    }
}
