//
//  AudioSessionManager.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/22/25.
//
import AVFoundation
func configureAudioSession() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        print("Audio session configured successfully.")
    } catch {
        print("Error configuring audio session: \(error)")
    }
}
