//
//  AudioSessionManager.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/22/25.
//
import AVFoundation

class AudioSessionManager {
    static let shared = AudioSessionManager() // Singleton instance

    public let audioEngine = AVAudioEngine()
    private let eqNode = AVAudioUnitEQ(numberOfBands: 1) // EQ node for filtering
    
    private(set) var isRecording = false
    private(set) var statusMessage = "Microphone access not requested yet."
    let audioSession = AVAudioSession.sharedInstance()
    let volumeThreshold: Float = 0.0000009 // Adjust this value based on your requirements

    // Computed property for available inputs
    var availableInputs: [AVAudioSessionPortDescription]? {
        return AVAudioSession.sharedInstance().availableInputs
    }

    // Callback to notify when audio buffers are available
    var audioBufferCallback: ((AVAudioPCMBuffer) -> Void)?

    private init() {
        configureEQNode() // Configure EQ node at initialization
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

    private func configureEQNode() {
        // Configure EQ for a band-pass filter
        let eqBand = eqNode.bands[0]
        eqBand.filterType = .bandPass
        eqBand.frequency = 1030.0   // Center frequency (Hz)
        eqBand.bandwidth = 3.32    // Bandwidth in octaves (~60 Hz to 2000 Hz)
        eqBand.gain = 4.0         // Gain in dB
        eqBand.bypass = false
    }

    func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            // Configure audio session
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetooth, .allowBluetoothA2DP])
            //try session.setMode(.videoRecording)
            try session.setActive(true)

            // Attach nodes
            let inputNode = audioEngine.inputNode
            audioEngine.attach(eqNode)

            // Connect nodes: Input -> EQ -> Main Mixer
            audioEngine.connect(inputNode, to: eqNode, format: inputNode.inputFormat(forBus: 0))
            audioEngine.connect(eqNode, to: audioEngine.mainMixerNode, format: inputNode.inputFormat(forBus: 0))

            // Remove existing tap before installing a new one
            inputNode.removeTap(onBus: 0)
            eqNode.removeTap(onBus: 0) // Remove tap from eqNode
            // Install a tap on the EQ node  (32768)
            eqNode.installTap(onBus: 0, bufferSize: 16384 , format: inputNode.inputFormat(forBus: 0)) { [weak self] buffer, _ in
                guard let self = self else { return }
                self.processAudio(buffer: buffer)
                self.audioBufferCallback?(buffer) // Notify the callback
            }

            // Prepare and start the audio engine
            audioEngine.prepare()
            try audioEngine.start()

            isRecording = true
            statusMessage = "Audio engine started successfully."
        } catch {
            statusMessage = "Audio engine couldn't start: \(error.localizedDescription)"
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
        eqNode.removeTap(onBus: 0) // Remove tap from eqNode
        isRecording = false
    }

    private func processAudio(buffer: AVAudioPCMBuffer) {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        let audioData = audioBuffer.mData?.assumingMemoryBound(to: Float.self)
        let audioDataArray = UnsafeMutableBufferPointer(start: audioData, count: Int(buffer.frameLength))
        // Apply threshold filtering
        let rms = sqrt(audioDataArray.reduce(0) { $0 + $1 * $1 } / Float(audioDataArray.count))
        
        if rms > self.volumeThreshold {
            DispatchQueue.main.async {
                self.statusMessage = "Valid audio data received with RMS: \(rms)"
            }
        } else {
            DispatchQueue.main.async {
                self.statusMessage = "Low audio signal. RMS: \(rms)"
            }
        }

        // Zero out samples below the threshold
        for i in audioDataArray.indices {
            if abs(audioDataArray[i]) < self.volumeThreshold {
                audioDataArray[i] = 0
            }
        }

        // Pass the processed buffer to the callback
        self.audioBufferCallback?(buffer)
    }
}
