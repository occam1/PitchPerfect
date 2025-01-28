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
    let utility = Utility.shared
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
        let exerciseManager = ExerciseManager.shared
        var currentNote: String?
        if PitchPerfectApp.doDebug {
            print("AM rGL isRunning ,\(isRunning)")
        }


        while isRunning {
            print("Starting rGL loop")
            print("automatic , \(pitchCompareModel.isAutomatic) or paused , \(pitchCompareModel.isPaused)")
            // Handle automatic vs. manual mode
            //if !pitchCompareModel.isAutomatic {
              //  print("Manual mode active, waiting for user to press Next")
                while pitchCompareModel.isPaused && isRunning {
                    print("pausing , \(pitchCompareModel.isPaused)")
                   
                    Thread.sleep(forTimeInterval: 0.1) // Small sleep to avoid high CPU usage
                }
                if !isRunning { break } // Exit if the game is stopped while paused
           // }
            // Get the next note from the current exercise
             guard let nextNote = exerciseManager.currentExercise().nextNote(currentNote: currentNote) else {
                 exerciseManager.selectNextExercise()
                 exerciseManager.resetCurrentExercise()
                 continue
             }

             currentNote = nextNote
          
            // Get the frequency for the current label
            guard let frequency = AppDataManager.noteFrequencies[nextNote] else {
                print("Frequency not found for label: \(nextNote)")
                continue // Skip the current iteration if frequency is nil
            }
            let label = utility.convertToNoteOctave(from: nextNote)
            // Update the PitchCompareModel with the generated frequency and label
            DispatchQueue.main.async {
                self.pitchCompareModel.updateGeneratedFrequency(to: frequency, label: label)
            }

            // Play the tone
            print("Running game loop, playing tone")
            tonePlayer.startPlayingTone(frequency: frequency, duration: 8)
            print("end of GL - automatic , \(pitchCompareModel.isAutomatic) is Paused , \(pitchCompareModel.isPaused)")
            
            // Pause between pitches
              if pitchCompareModel.isAutomatic {
                  print("Pausing for user to catch their breath")
                  Thread.sleep(forTimeInterval: 1) // Pause for 2 seconds between pitches
              } else {
                  // In manual mode, set isPaused back to true after the pitch
                  print("dispatching the pause button change to true")
                    DispatchQueue.main.async {
                      self.pitchCompareModel.isPaused = true
                    }
                }
            Thread.sleep(forTimeInterval: 1) // Pause for 2 seconds between pitches
        }
    }
}
