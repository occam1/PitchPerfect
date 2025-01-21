//
//  ConfigurationView.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//
import SwiftUI

struct ConfigurationView: View {
    @Binding var users: [UserData]
    @Binding var selectedUser: UserData?
    @Binding var showConfiguration: Bool

    @State private var showAdvancedSettings: Bool = false
    @State private var newUserName: String = ""
    @State private var level: Int = 1

    var body: some View {
        NavigationView {
            Form {
                // Section for existing users
                Section(header: Text("Existing Users")) {
                    ForEach(users, id: \.userName) { user in
                        HStack {
                            Button(action: {
                                handleUserSelection(user: user)
                            }) {
                                Text(user.userName)
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            // Show checkmark for selected user
                            if selectedUser?.userName == user.userName {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    // Advanced Settings button for the selected user
                    if let selectedUser = selectedUser {
                        Button("Edit \(selectedUser.userName)'s Advanced Settings") {
                            showAdvancedSettings = true
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                }

                // Section for adding new users
                Section(header: Text("Add New User")) {
                    TextField("Enter new user name", text: $newUserName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Picker("Level", selection: $level) {
                        Text("Beginner (1)").tag(1)
                        Text("Intermediate (2)").tag(2)
                        Text("Expert (3)").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Button(action: {
                        addNewUser()
                    }) {
                        Text("Add User")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Configuration")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showConfiguration = false
                    }
                }
            }
            .sheet(isPresented: $showAdvancedSettings) {
                if let selectedUserIndex = users.firstIndex(where: { $0.userName == selectedUser?.userName }) {
                    AdvancedSettingsView(
                        advancedSettings: $users[selectedUserIndex].advancedSettings,
                        showAdvancedSettings: $showAdvancedSettings,
                        user: $users[selectedUserIndex]
                    )
                }
            }
        }
    }

    // Handle user selection
    private func handleUserSelection(user: UserData) {
        selectedUser = user
        showAdvancedSettings = true // Force all users to go to Advanced Settings
    }

    // Add a new user
    private func addNewUser() {
        guard !newUserName.isEmpty, !users.contains(where: { $0.userName == newUserName }) else { return }

        let newUser = UserData(
            userName: newUserName,
            attempts: [],
            advancedSettings: AdvancedSettings(
                lowestNote: "",
                highestNote: "",
                selectedKey: "C"
            )
        )
        users.append(newUser)
        UserDataManager.saveUserData(newUser)
        handleUserSelection(user: newUser) // Navigate new user to Advanced Settings
        newUserName = ""
    }
}
