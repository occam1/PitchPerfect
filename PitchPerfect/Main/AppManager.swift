//
//  AppManager.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/22/25.
//
import Foundation

class AppManager: ObservableObject {
    private let tonePlayer = TonePlayer()
    private let pitchCompareModel = PitchCompareModel()
    private lazy var toneGetter = ToneGetter(model: pitchCompareModel)
    private var isRunning = false

    func startProcesses() {
        if !isRunning {
            Task {
                print("Starting Task.")
                toneGetter.startCapture()
                tonePlayer.startPlayingTone(frequency: 440.0) // Example tone
                isRunning = true
            }
        }
    }

    func pauseProcesses() {
        if isRunning {
            toneGetter.stopCapture()
            tonePlayer.stopPlaying()
            isRunning = false
        }
    }

    func resumeProcesses() {
        startProcesses()
    }
}
