//
//  GoalsView.swift
//  127DeepWork
//

import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: DeepWorkViewModel
    @State private var showEditGoalsSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 18) {
                    if let dailyGoal = viewModel.dailyGoal {
                        GoalCard(
                            title: "Daily goal",
                            current: dailyGoal.currentMinutes,
                            target: dailyGoal.targetMinutes,
                            unit: "min",
                            isCompleted: dailyGoal.isCompleted
                        )
                    }
                    if let weeklyGoal = viewModel.weeklyGoal {
                        GoalCard(
                            title: "Weekly goal",
                            current: weeklyGoal.currentMinutes,
                            target: weeklyGoal.targetMinutes,
                            unit: "min",
                            isCompleted: weeklyGoal.isCompleted
                        )
                    }
                    Button {
                        showEditGoalsSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .font(.headline)
                            Text("Edit goals")
                                .font(.headline.weight(.semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .opacity(0.7)
                        }
                        .foregroundColor(.deepBackground)
                        .padding(18)
                        .frame(maxWidth: .infinity)
                        .deepPrimaryCTA(cornerRadius: 18)
                    }
                    .buttonStyle(.plain)
                    .shadow(color: Color.deepAccent.opacity(0.35), radius: 14, x: 0, y: 8)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .padding(.top, 8)
            }
            .deepScreenBackdrop()
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.deepBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showEditGoalsSheet) {
                EditGoalsView(viewModel: viewModel, isPresented: $showEditGoalsSheet)
            }
        }
    }
}
