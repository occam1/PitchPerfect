import SwiftUI

struct ContentView: View {
    @StateObject private var pitchCompareModel = PitchCompareModel()
    @State private var showSettings: Bool = false
    @State private var users: [UserData] = [] // Placeholder for users data
    @State private var selectedUser: UserData? = nil // Placeholder for selected user

    var body: some View {
        NavigationView {
            VStack {
                // Main Pitch Comparison View
                PitchComparisonView(model: pitchCompareModel)

                // Simulate Detection Button
                Button("Simulate Detection") {
                    let simulatedFrequency = Float.random(in: 400...480) // Simulate a detected frequency
                    pitchCompareModel.updateDetectedFrequency(simulatedFrequency)
                }
                .padding()

                // Match Result
                Text(pitchCompareModel.matchResult)
                    .font(.title)
                    .foregroundColor(pitchCompareModel.matchResult == "Matched" ? .green : .red)
                    .padding()

                Spacer()

                // Settings Button
                Button(action: {
                    showSettings = true
                }) {
                    Text("Settings")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showSettings) {
                    ConfigurationView(users: $users, selectedUser: $selectedUser, showConfiguration: $showSettings)
                }
            }
            .navigationTitle("PitchPerfect")
            .onAppear {
                // Perform Initialization
                Init.configureAudioSession()
                AppDataManager.initialize()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

