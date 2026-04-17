//
//  TasksView.swift
//  127DeepWork
//

import SwiftUI

struct TasksView: View {
    @ObservedObject var viewModel: DeepWorkViewModel
    @State private var showAddTaskSheet = false
    @State private var selectedTask: FocusTask?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                List {
                    ForEach(viewModel.tasks) { task in
                        TaskCard(task: task)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .contentShape(Rectangle())
                            .onTapGesture { selectedTask = task }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.deleteTask(task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    viewModel.toggleTaskCompletion(task)
                                } label: {
                                    Label(task.isCompleted ? "Undo" : "Complete", systemImage: "checkmark")
                                }
                                .tint(.deepAccent)
                            }
                    }
                    Section {
                        Button {
                            showAddTaskSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add task")
                                    .font(.headline.weight(.semibold))
                                Spacer()
                            }
                            .foregroundColor(.deepBackground)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .deepPrimaryCTA(cornerRadius: 18)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 16, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .deepScreenBackdrop()
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.deepBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showAddTaskSheet) {
                TaskEditorView(viewModel: viewModel, task: nil)
            }
            .sheet(item: $selectedTask) { task in
                TaskEditorView(viewModel: viewModel, task: task)
            }
        }
    }
}
