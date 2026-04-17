//
//  ContentView.swift
//  127DeepWork
//

import SwiftUI

struct ContentView: View {
    @AppStorage("deepwork_onboarding_completed") private var onboardingCompleted = false
    @StateObject private var viewModel = DeepWorkViewModel()
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if onboardingCompleted {
                mainTabView
            } else {
                OnboardingView(viewModel: viewModel, onComplete: {
                    onboardingCompleted = true
                })
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            StatsView(viewModel: viewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(1)

            TasksView(viewModel: viewModel)
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(2)

            GoalsView(viewModel: viewModel)
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(3)

            AnalyticsView(viewModel: viewModel)
                .tabItem {
                    Label("Analytics", systemImage: "brain")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .onAppear {
            viewModel.loadFromUserDefaults()
        }
        .tint(.deepAccent)
        .deepScreenBackdrop()
    }
}

#Preview {
    ContentView()
}
