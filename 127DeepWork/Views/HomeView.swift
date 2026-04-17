//
//  HomeView.swift
//  127DeepWork
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: DeepWorkViewModel
    @Binding var selectedTab: Int
    @State private var showNewSessionSheet = false
    @State private var selectedSession: WorkSession?
    @State private var focusGlow = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    heroCard
                    quickDestinationsRow
                    statsGrid
                    if let goal = viewModel.todayGoal {
                        todayGoalCard(goal)
                    } else {
                        setGoalHintButton
                    }
                    focusBlock
                }
                .padding(.vertical, 4)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            Section {
                if viewModel.recentSessions.isEmpty {
                    emptySessionsPlaceholder
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(viewModel.recentSessions) { session in
                        SessionRow(session: session)
                            .listRowBackground(Color.deepCard)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .contentShape(Rectangle())
                            .onTapGesture { selectedSession = session }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteSession(session)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            } header: {
                recentSectionHeader
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .deepScreenBackdrop()
        .refreshable {
            viewModel.refreshDashboard()
        }
        .sheet(isPresented: $showNewSessionSheet) {
            NewSessionView(viewModel: viewModel, isPresented: $showNewSessionSheet)
        }
        .sheet(item: $selectedSession) { session in
            SessionDetailSheet(session: session, viewModel: viewModel)
        }
        .onAppear { syncFocusGlow() }
        .onChange(of: viewModel.activeSession) { newSession in
            focusGlow = newSession?.status == .active
        }
    }

    private func syncFocusGlow() {
        focusGlow = viewModel.activeSession?.status == .active
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(timeGreeting)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)
                    Text(formattedFullDate)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.deepAccent, Color.deepAccent.opacity(0.75)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.deepAccent.opacity(0.35), radius: 8, x: 0, y: 0)
                    if viewModel.completedSessionsTodayCount > 0 {
                        Label(
                            viewModel.completedSessionsTodayCount == 1
                                ? "1 session finished today"
                                : "\(viewModel.completedSessionsTodayCount) sessions finished today",
                            systemImage: "checkmark.circle.fill"
                        )
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
                Spacer(minLength: 8)
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.deepAccent.opacity(0.45), Color.deepAccent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: Color.deepAccent.opacity(0.4), radius: 12, x: 0, y: 4)
                    Image(systemName: "scope")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.deepAccent, Color.deepAccent.opacity(0.65)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .deepElevatedPanel(cornerRadius: 22, accentRim: true, glowAccent: false, elevation: .floating)
    }

    private var quickDestinationsRow: some View {
        HStack(spacing: 10) {
            quickPill(title: "Stats", systemImage: "chart.bar.fill", tab: 1)
            quickPill(title: "Tasks", systemImage: "checklist", tab: 2, badge: viewModel.openTasksCount)
            quickPill(title: "Goals", systemImage: "target", tab: 3)
        }
    }

    private func quickPill(title: String, systemImage: String, tab: Int, badge: Int = 0) -> some View {
        Button {
            selectedTab = tab
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.semibold))
                if badge > 0 {
                    Text("\(badge)")
                        .font(.caption2.bold())
                        .foregroundColor(.deepBackground)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.deepAccent))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .deepElevatedPanel(cornerRadius: 14, elevation: .soft)
        }
        .buttonStyle(.plain)
    }

    private var statsGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            HomeMetricTile(
                title: "Today",
                value: "\(viewModel.todayMinutes)",
                unit: "min",
                icon: "sun.max.fill"
            )
            HomeMetricTile(
                title: "This week",
                value: "\(viewModel.weeklyMinutes)",
                unit: "min",
                icon: "calendar"
            )
            HomeMetricTile(
                title: "All time",
                value: formatTotalDuration(viewModel.totalMinutes),
                unit: "",
                icon: "clock.fill"
            )
            HomeMetricTile(
                title: "Sessions",
                value: "\(viewModel.totalSessions)",
                unit: "logged",
                icon: "list.bullet"
            )
        }
    }

    private func todayGoalCard(_ goal: DailyGoal) -> some View {
        HStack(alignment: .center, spacing: 18) {
            ZStack {
                Circle()
                    .stroke(Color.deepBackground, lineWidth: 7)
                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(Color.deepAccent, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
            }
            .frame(width: 62, height: 62)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Today's goal")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    if goal.isCompleted {
                        Text("Done")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.deepBackground)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.deepAccent))
                    }
                }
                Text("\(goal.currentMinutes) / \(goal.targetMinutes) minutes")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                ProgressView(value: goal.progress)
                    .tint(.deepAccent)
                    .scaleEffect(x: 1, y: 1.4, anchor: .center)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .deepElevatedPanel(
            cornerRadius: 20,
            accentRim: true,
            glowAccent: goal.isCompleted,
            elevation: .floating
        )
    }

    private var setGoalHintButton: some View {
        Button {
            selectedTab = 3
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "target")
                    .font(.title3)
                    .foregroundColor(.deepAccent)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Set a daily goal")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Track how much focus time you want each day.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.deepAccent)
            }
            .padding(18)
            .deepElevatedPanel(cornerRadius: 20, accentRim: false, glowAccent: false, elevation: .floating)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var focusBlock: some View {
        if let active = viewModel.activeSession {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    statusBadge(for: active.status)
                    Spacer()
                    Text(active.formattedDuration())
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(.deepAccent)
                        .monospacedDigit()
                }
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: active.activityType.icon)
                        .font(.title2)
                        .foregroundColor(.deepAccent)
                        .frame(width: 36, alignment: .center)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(active.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(active.activityType.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer(minLength: 0)
                }
                HStack(spacing: 12) {
                    if active.status == .paused {
                        secondaryControl(title: "Resume", systemImage: "play.fill") {
                            viewModel.resumeSession()
                        }
                    } else {
                        secondaryControl(title: "Pause", systemImage: "pause.fill") {
                            viewModel.pauseSession()
                        }
                    }
                    primaryControl(title: "Stop", systemImage: "stop.fill") {
                        viewModel.stopSession()
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .deepElevatedPanel(cornerRadius: 22, accentRim: true, glowAccent: true, elevation: .floating)
            .shadow(color: Color.deepAccent.opacity(focusGlow ? 0.42 : 0.2), radius: focusGlow ? 24 : 14, x: 0, y: 6)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: focusGlow)
        } else {
            Button {
                showNewSessionSheet = true
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.deepBackground.opacity(0.4))
                            .frame(width: 52, height: 52)
                            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                        Image(systemName: "play.fill")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.deepBackground)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start focus session")
                            .font(.headline)
                            .foregroundColor(.deepBackground)
                        Text("Begin tracking deep work with a timer.")
                            .font(.caption)
                            .foregroundColor(.deepBackground.opacity(0.75))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.deepBackground.opacity(0.5))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .deepPrimaryCTA(cornerRadius: 22)
            }
            .buttonStyle(.plain)
        }
    }

    private func statusBadge(for status: SessionStatus) -> some View {
        let text: String
        let icon: String
        switch status {
        case .active:
            text = "Live"
            icon = "dot.radiowaves.left.and.right"
        case .paused:
            text = "Paused"
            icon = "pause.circle.fill"
        default:
            text = status.rawValue
            icon = "circle.fill"
        }
        return Label(text, systemImage: icon)
            .font(.caption.weight(.bold))
            .foregroundColor(status == .active ? .deepBackground : .white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(status == .active ? DeepGradients.accentCTA : LinearGradient(colors: [Color.deepBackground.opacity(0.75), Color.deepBackground.opacity(0.5)], startPoint: .top, endPoint: .bottom))
            )
            .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
    }

    private func secondaryControl(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(DeepGradients.cardFace)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private func primaryControl(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(DeepGradients.accentCTA)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                        )
                )
                .foregroundColor(.deepBackground)
                .shadow(color: Color.deepAccent.opacity(0.45), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }

    private var emptySessionsPlaceholder: some View {
        VStack(spacing: 14) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.deepAccent.opacity(0.65))
            Text("No sessions yet")
                .font(.headline)
                .foregroundColor(.white)
            Text("Pull down to refresh goals, or start a focus session above.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .deepElevatedPanel(cornerRadius: 20, elevation: .soft)
    }

    private var recentSectionHeader: some View {
        HStack {
            Text("Recent sessions")
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            if !viewModel.recentSessions.isEmpty {
                Text("Last \(viewModel.recentSessions.count)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.gray)
            }
        }
        .textCase(nil)
        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
    }

    private var timeGreeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    private var formattedFullDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }

    private func formatTotalDuration(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

// MARK: - Metric tile

private struct HomeMetricTile: View {
    let title: String
    let value: String
    let unit: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.deepAccent)
                .symbolRenderingMode(.hierarchical)
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(.gray)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .deepElevatedPanel(cornerRadius: 18, elevation: .floating)
    }
}

#Preview {
    HomeView(viewModel: DeepWorkViewModel(), selectedTab: .constant(0))
}
