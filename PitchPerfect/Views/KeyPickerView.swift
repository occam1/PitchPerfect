//
//  KeyPickerView.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//
import SwiftUI

struct KeyPickerView: View {
    let keys: [String]
    @Binding var selectedKey: String

    var body: some View {
        ForEach(keys, id: \.self) { key in
            HStack {
                Text(key)
                Spacer()
                if key == selectedKey {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle()) // Makes the whole row tappable
            .onTapGesture {
                selectedKey = key
            }
        }
    }
}
