//
//  ShowUserSelection.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/2/25.
//
import SwiftUI
import SwiftUI

struct UserSelectionView: View {
    @Binding var users: [UserData]
    @Binding var selectedUser: UserData?
    @Binding var showUserSelection: Bool

    @State private var newUserName: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select a User")) {
                    ForEach(users, id: \.userName) { user in
                        Button(action: {
                            selectUser(user: user)
                        }) {
                            HStack {
                                Text(user.userName)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedUser?.userName == user.userName {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Create New User")) {
                    TextField("Enter new user name", text: $newUserName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: createNewUser) {
                        Text("Create User")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Select User")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if selectedUser == nil {
                            print("⚠️ Cannot dismiss, no user selected.")
                            return
                        }
                        showUserSelection = false // ✅ Close selection
                    }
                }
            }
        }
        .onDisappear {
            // ✅ When the view disappears, it ensures processes resume only if a user is set.
            if let activeUser = selectedUser {
                print("✅ Selected user: \(activeUser.userName)")
                UserData.setActiveUser(user: activeUser)
            }
        }
    }

    private func selectUser(user: UserData) {
        selectedUser = user
        UserData.setActiveUser(user: user)
        showUserSelection = false // ✅ Dismiss view
    }

    private func createNewUser() {
        guard !newUserName.isEmpty, !users.contains(where: { $0.userName == newUserName }) else { return }

        UserData.createNewUser(userName: newUserName) // ✅ Create & save new user
        selectedUser = UserData.shared
        users.append(selectedUser!)
        showUserSelection = false // ✅ Dismiss view
    }
}
