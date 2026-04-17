//
//  TaskEditorView.swift
//  127DeepWork
//

import SwiftUI

struct TaskEditorView: View {
    @ObservedObject var viewModel: DeepWorkViewModel
    var task: FocusTask?
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var priority: Int = 3
    @State private var estimatedTime: Int = 30
    @State private var actualTime: Int = 0
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var isImportant = false

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section {
                        TextField("Title", text: $title)
                            .foregroundColor(.white)
                            .tint(.deepAccent)
                        TextField("Description (optional)", text: $descriptionText, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundColor(.white)
                            .tint(.deepAccent)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.deepCard.opacity(0.65))
                            .padding(.vertical, 2)
                    )
                    Section {
                        Stepper("Priority: \(priority)/5", value: $priority, in: 1...5)
                        Stepper("Estimate: \(estimatedTime) min", value: $estimatedTime, in: 5...480, step: 5)
                        if task != nil {
                            Stepper("Actual: \(actualTime) min", value: $actualTime, in: 0...1440, step: 5)
                        }
                        Toggle("Important", isOn: $isImportant)
                            .tint(.deepAccent)
                        Toggle("Deadline", isOn: $hasDeadline)
                            .tint(.deepAccent)
                        if hasDeadline {
                            DatePicker("Due date", selection: $deadline, displayedComponents: .date)
                                .tint(.deepAccent)
                        }
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
            .navigationTitle(task == nil ? "New task" : "Edit task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.deepBackground.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.deepAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.deepAccent)
                        .bold()
                }
            }
            .onAppear {
                if let t = task {
                    title = t.title
                    descriptionText = t.description ?? ""
                    priority = t.priority
                    estimatedTime = t.estimatedTime
                    actualTime = t.actualTime
                    isImportant = t.isImportant
                    if let d = t.deadline {
                        hasDeadline = true
                        deadline = d
                    }
                }
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmed.isEmpty ? "Untitled" : trimmed
        let desc = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        if var existing = task {
            existing.title = finalTitle
            existing.description = desc.isEmpty ? nil : desc
            existing.priority = priority
            existing.estimatedTime = estimatedTime
            existing.actualTime = actualTime
            existing.deadline = hasDeadline ? deadline : nil
            existing.isImportant = isImportant
            viewModel.updateTask(existing)
        } else {
            let new = FocusTask(
                id: UUID(),
                title: finalTitle,
                description: desc.isEmpty ? nil : desc,
                priority: priority,
                estimatedTime: estimatedTime,
                actualTime: actualTime,
                deadline: hasDeadline ? deadline : nil,
                isCompleted: false,
                isImportant: isImportant,
                createdAt: Date()
            )
            viewModel.addTask(new)
        }
        dismiss()
    }
}
