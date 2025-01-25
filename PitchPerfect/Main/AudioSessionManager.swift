//
//  AudioSessionManager.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/22/25.
//
import AVFoundation

class AudioSessionManager {
    static let shared = AudioSessionManager() // Singleton instance

    private let audioEngine = AVAudioEngine()
    private(set) var isRecording = false
    private(set) var statusMessage = "Microphone access not requested yet."

    let volumeThreshold: Float = 0.09 // Adjust this value based on your requirements

    // Computed property for available inputs
    var availableInputs: [AVAudioSessionPortDescription]? {
        return AVAudioSession.sharedInstance().availableInputs
    }

    // Callback to notify when audio buffers are available
    var audioBufferCallback: ((AVAudioPCMBuffer) -> Void)?

    private init() {
        // Observe input route changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)

        switch authorizationStatus {
        case .authorized:
            configureAudioSession()
            completion(true)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.configureAudioSession()
                    } else {
                        self?.statusMessage = "Microphone access denied."
                    }
                    completion(granted)
                }
            }

        case .denied, .restricted:
            DispatchQueue.main.async {
                self.statusMessage = "Microphone access denied."
                completion(false)
            }

        @unknown default:
            DispatchQueue.main.async {
                self.statusMessage = "Unknown microphone authorization status."
                completion(false)
            }
        }
    }

    func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        print("Available Inputs: \(availableInputs?.map { $0.portName } ?? ["None"])")
        print("ASM session sample rate ,\(session.sampleRate)")

        do {
            // Configure audio session
            try session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try session.setActive(true)

            if let bluetoothInput = availableInputs?.first(where: { $0.portType == .bluetoothHFP }) {
                try session.setPreferredInput(bluetoothInput)
                statusMessage = "Bluetooth microphone set as input: \(bluetoothInput.portName)"
            } else {
                statusMessage = "Bluetooth microphone not found."
            }

            // Attach and configure audio nodes
            let inputNode = audioEngine.inputNode

            let inputFormat = inputNode.inputFormat(forBus: 0)
            print("Input Node Format Sample Rate: \(inputFormat.sampleRate)")
            // Remove existing tap before installing a new one
            inputNode.removeTap(onBus: 0)

            // Install a tap on the inputNode to capture audio data
            inputNode.installTap(onBus: 0, bufferSize: 16384, format: inputNode.inputFormat(forBus: 0)) { [weak self] buffer, _ in
                guard let self = self else { return }
                self.processAudio(buffer: buffer)
                self.audioBufferCallback?(buffer) // Notify the callback
            }

            // Prepare and start the audio engine
            audioEngine.prepare()
            try audioEngine.start()

            isRecording = true
            statusMessage += "\nAudio engine started successfully."
            print("Audio engine started successfully.")
        } catch {
            statusMessage = "Audio engine couldn't start: \(error.localizedDescription)"
            print("Error: \(error.localizedDescription)")
        }
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        switch reason {
        case .newDeviceAvailable:
            print("New input device available. Reconfiguring audio session.")
            reconfigureAudioGraph()
        case .oldDeviceUnavailable:
            print("Input device removed. Reconfiguring audio session.")
            reconfigureAudioGraph()
        default:
            break
        }
    }

    private func reconfigureAudioGraph() {
        print("Reconfiguring audio graph...")
        stopAudioSession()
        configureAudioSession()
    }

    func stopAudioSession() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isRecording = false
    }

    private func processAudio(buffer: AVAudioPCMBuffer) {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        let audioData = audioBuffer.mData?.assumingMemoryBound(to: Float.self)
        let audioDataArray = UnsafeBufferPointer(start: audioData, count: Int(buffer.frameLength))

        // Calculate RMS for volume analysis
        let rms = sqrt(audioDataArray.reduce(0) { $0 + $1 * $1 } / Float(audioDataArray.count))

        DispatchQueue.main.async {
            if rms > self.volumeThreshold {
                self.statusMessage = "Valid audio data received with RMS: \(rms)"
              //  print("Valid audio data received with RMS: \(rms)")
            } else {
                self.statusMessage = "No valid audio data above threshold."
               //44100
                print("No valid audio data above threshold. RMS: \(rms)")
            }
        }
    }
}
