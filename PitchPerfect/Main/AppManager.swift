//
//  AppManager.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/22/25.
//
import UIKit
import Foundation

class AppManager: ObservableObject {
    static let shared = AppManager() // Define the singleton instance
    let audioSessionManager = AudioSessionManager.shared
    private let tonePlayer = TonePlayer()
    private let pitchCompareModel = PitchCompareModel()
    private lazy var toneGetter = ToneGetter(model: pitchCompareModel)
    private var isRunning = false

    public init() {
        setupBluetoothAndMicrophone()
    }

    private func setupBluetoothAndMicrophone() {

        // Request microphone permissions
        audioSessionManager.requestPermissions { granted in
            if granted {
                self.audioSessionManager.configureAudioSession()
                self.verifyBluetoothInput()
            } else {
                self.handlePermissionFailure()
            }
        }
    }

    private func verifyBluetoothInput() {
        let availableInputs = audioSessionManager.availableInputs

        if let bluetoothInput = availableInputs?.first(where: { $0.portType == .bluetoothHFP }) {
            print("Bluetooth input verified: \(bluetoothInput.portName)")
        } else {
            handleBluetoothFailure()
        }
    }

    private func handlePermissionFailure() {
        // Inform the user that microphone permissions are required
        print("Microphone access is required for this app to function. Please enable it in Settings.")
        // Optionally show an alert to direct the user to Settings
        redirectToSettings()
    }

    private func handleBluetoothFailure() {
        // Inform the user that Bluetooth input is required
        print("Bluetooth input is required for this app to function. Please connect a Bluetooth microphone.")
        // Optionally show an alert to guide the user
    }

    private func redirectToSettings() {
        // Open the Settings app to allow the user to grant microphone permissions
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
 
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
