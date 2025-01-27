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
    private let pitchCompareModel = PitchCompareModel.shared
    private lazy var toneGetter = ToneGetter()
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
                    runGameLoop()
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
    
    private func runGameLoop() {
        // Logic for the main game loop
        if PitchPerfectApp.doDebug {
            print("AM rGL isRunning ,\(isRunning)")
        }

        var i = 0
        var j = 3
        var label : String
        while isRunning {
           
            print("starting rGL loop")
            if i < AppDataManager.keys.count - 1
            {
                i += 1
            } else {
                i = 0
                if j >= 5 {
                 j = 2
                } else {j += 1}
                
            }
            
            print(" I ,\(i) and J,\(j) ")
            label = AppDataManager.keys[i] + String(j)
            print(" I ,\(i) and J,\(j) and LABEL \(label)")
            guard let frequency = AppDataManager.noteFrequencies[label] else {
                print("Frequency not found for label: \(label)")
                continue // Skip the current iteration if frequency is nil
            }
            
                print("Running game loop  updating frequency")
            
            
            //pitchCompareModel.updateCurrentNoteLabel(to: label)
            DispatchQueue.main.async {
                self.pitchCompareModel.updateGeneratedFrequency(to: frequency, label: label)
            }
            print("Running game loop  playing tone")
            tonePlayer.startPlayingTone(frequency: frequency,  duration: 5)
            // Perform tasks like tone generation, frequency analysis, etc.
        }
    }
}
