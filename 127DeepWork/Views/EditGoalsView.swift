//
//  EditGoalsView.swift
//  127DeepWork
//

import SwiftUI

struct EditGoalsView: View {
    @ObservedObject var viewModel: DeepWorkViewModel
    @Binding var isPresented: Bool
    @State private var dailyTarget: Int = 120
    @State private var weeklyTarget: Int = 600

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section {
                        Stepper("Daily target: \(dailyTarget) min", value: $dailyTarget, in: 15...960, step: 15)
                        Stepper("Weekly target: \(weeklyTarget) min", value: $weeklyTarget, in: 60...10080, step: 30)
                    } footer: {
                        Text("Targets apply from today and this week.")
                            .foregroundColor(.gray)
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
            .navigationTitle("Edit goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.deepBackground.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(.deepAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.setDailyGoal(minutes: dailyTarget)
                        viewModel.setWeeklyGoal(minutes: weeklyTarget)
                        isPresented = false
                    }
                    .foregroundColor(.deepAccent)
                    .bold()
                }
            }
            .onAppear {
                dailyTarget = viewModel.dailyGoal?.targetMinutes ?? 120
                weeklyTarget = viewModel.weeklyGoal?.targetMinutes ?? 600
            }
        }
    }
}
