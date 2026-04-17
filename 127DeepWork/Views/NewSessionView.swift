//
//  NewSessionView.swift
//  127DeepWork
//

import SwiftUI

struct NewSessionView: View {
    @ObservedObject var viewModel: DeepWorkViewModel
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var activityType: ActivityType = .work
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section {
                        TextField("Title", text: $title)
                            .foregroundColor(.white)
                            .tint(.deepAccent)
                        Picker("Activity type", selection: $activityType) {
                            ForEach(ActivityType.allCases, id: \.self) { type in
                                Label(type.rawValue, systemImage: type.icon).tag(type)
                            }
                        }
                        .tint(.deepAccent)
                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .foregroundColor(.white)
                            .tint(.deepAccent)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.deepCard.opacity(0.65))
                            .padding(.vertical, 2)
                    )
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .deepScreenBackdrop()
            .navigationTitle("New session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.deepBackground.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.deepAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let finalTitle = trimmed.isEmpty ? "Untitled" : trimmed
                        let n = notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        viewModel.startSession(
                            title: finalTitle,
                            activityType: activityType,
                            notes: n.isEmpty ? nil : n
                        )
                        isPresented = false
                    }
                    .foregroundColor(.deepAccent)
                    .bold()
                }
            }
        }
    }
}
