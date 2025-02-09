//
//  ExerciseView.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/8/25.
//
import SwiftUI
import SwiftUI

struct ExerciseView: View {
    @Binding var user: UserData
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(AppDataManager.exercises.keys.sorted(), id: \.self) { exerciseId in
                    ExerciseRow(exerciseId: exerciseId, user: $user) // ✅ Each row uses ExerciseRow
                }
            }
            .navigationTitle("Exercises")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        user.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
