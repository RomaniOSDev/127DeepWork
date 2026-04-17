//
//  DeepWorkViewModel.swift
//  127DeepWork
//

import Combine
import Foundation

@MainActor
final class DeepWorkViewModel: ObservableObject {
    @Published var sessions: [WorkSession] = []
    @Published var tasks: [FocusTask] = []
    @Published var dailyGoal: DailyGoal?
    @Published var weeklyGoal: WeeklyGoal?
    @Published var activeSession: WorkSession?

    private var tickCancellable: AnyCancellable?

    private let sessionsKey = "deepwork_sessions"
    private let tasksKey = "deepwork_tasks"
    private let dailyGoalKey = "deepwork_dailygoal"
    private let weeklyGoalKey = "deepwork_weeklygoal"
    private let activeSessionKey = "deepwork_active_session"

    private func minutesToday() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let completed = sessions.filter { $0.endTime != nil && calendar.isDate($0.startTime, inSameDayAs: today) }
            .reduce(0) { $0 + $1.duration } / 60
        if let a = activeSession, calendar.isDate(a.startTime, inSameDayAs: today) {
            return completed + a.elapsedSeconds() / 60
        }
        return completed
    }

    private func minutesLast7Days() -> Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let completed = sessions.filter { $0.endTime != nil && $0.startTime >= weekAgo }
            .reduce(0) { $0 + $1.duration } / 60
        if let a = activeSession, a.startTime >= weekAgo {
            return completed + a.elapsedSeconds() / 60
        }
        return completed
    }

    var todayMinutes: Int { minutesToday() }

    var weeklyMinutes: Int { minutesLast7Days() }

    var totalMinutes: Int {
        let completed = sessions.filter { $0.endTime != nil }.reduce(0) { $0 + $1.duration } / 60
        if let a = activeSession {
            return completed + a.elapsedSeconds() / 60
        }
        return completed
    }

    var totalHours: Int {
        totalMinutes / 60
    }

    var totalSessions: Int {
        sessions.count
    }

    var averageDaily: Int {
        let daysWithSessions = Set(sessions.filter { $0.endTime != nil }.map { Calendar.current.startOfDay(for: $0.startTime) }).count
        guard daysWithSessions > 0 else { return 0 }
        return totalMinutes / daysWithSessions
    }

    var completionRate: Double {
        let completed = sessions.filter { $0.status == .completed }.count
        guard totalSessions > 0 else { return 0 }
        return Double(completed) / Double(totalSessions) * 100
    }

    var recentSessions: [WorkSession] {
        Array(sessions.sorted { $0.startTime > $1.startTime }.prefix(10))
    }

    var openTasksCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    /// Finished sessions whose start time is today (excludes active-only time).
    var completedSessionsTodayCount: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return sessions.filter { $0.endTime != nil && cal.isDate($0.startTime, inSameDayAs: today) }.count
    }

    var todayGoal: DailyGoal? {
        guard let dg = dailyGoal, Calendar.current.isDate(dg.date, inSameDayAs: Date()) else { return nil }
        return dg
    }

    struct WeeklyActivity: Identifiable {
        let id: Date
        let day: String
        let minutes: Int
    }

    var weeklyActivity: [WeeklyActivity] {
        let calendar = Calendar.current
        let today = Date()
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }.reversed()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "en_US")
        return weekDays.map { date in
            let minutes = sessions.filter { $0.endTime != nil && calendar.isDate($0.startTime, inSameDayAs: date) }
                .reduce(0) { $0 + $1.duration } / 60
            return WeeklyActivity(id: date, day: formatter.string(from: date), minutes: minutes)
        }
    }

    struct ActivityDistribution: Identifiable {
        var id: String { name }
        let name: String
        let icon: String
        let minutes: Int
        let percentage: Double
    }

    var activityDistribution: [ActivityDistribution] {
        let grouped = Dictionary(grouping: sessions.filter { $0.endTime != nil }, by: \.activityType)
        let base = sessions.filter { $0.endTime != nil }.reduce(0) { $0 + $1.duration } / 60
        let denom = max(Double(base), 1)
        return grouped.map { type, list in
            let minutes = list.reduce(0) { $0 + $1.duration } / 60
            return ActivityDistribution(
                name: type.rawValue,
                icon: type.icon,
                minutes: minutes,
                percentage: Double(minutes) / denom * 100
            )
        }.sorted { $0.minutes > $1.minutes }
    }

    var productivityByHour: [Int: Int] {
        var result: [Int: Int] = [:]
        for session in sessions where session.endTime != nil {
            let hour = Calendar.current.component(.hour, from: session.startTime)
            result[hour, default: 0] += session.duration / 60
        }
        return result
    }

    var mostProductiveHour: Int {
        productivityByHour.max { $0.value < $1.value }?.key ?? 0
    }

    var mostProductiveDay: String {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions.filter { $0.endTime != nil }) { session in
            calendar.component(.weekday, from: session.startTime)
        }
        let dayMinutes = grouped.map { day, list in
            (day: day, minutes: list.reduce(0) { $0 + $1.duration } / 60)
        }
        let best = dayMinutes.max { $0.minutes < $1.minutes }?.day ?? 2
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US")
        let symbols = cal.weekdaySymbols
        let idx = max(0, min(best - 1, symbols.count - 1))
        return symbols[idx]
    }

    struct TopDay: Identifiable {
        var id: Date { date }
        let date: Date
        let minutes: Int
    }

    var topDays: [TopDay] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions.filter { $0.endTime != nil }) { session in
            calendar.startOfDay(for: session.startTime)
        }
        return grouped.map { date, list in
            TopDay(date: date, minutes: list.reduce(0) { $0 + $1.duration } / 60)
        }
        .sorted { $0.minutes > $1.minutes }
        .prefix(5)
        .map { $0 }
    }

    var recommendations: [String] {
        var recs: [String] = []
        if averageDaily < 60 {
            recs.append("Try raising your daily focus target toward 60 minutes.")
        }
        if completionRate < 70, totalSessions > 0 {
            recs.append("Aim to finish sessions without long interruptions.")
        }
        if mostProductiveHour < 8 || mostProductiveHour > 18, !sessions.isEmpty {
            recs.append("Your peak focus time is outside typical working hours.")
        }
        if recs.isEmpty {
            recs.append("Great momentum — keep the rhythm going.")
        }
        return recs
    }

    func startSession(title: String, activityType: ActivityType, notes: String?) {
        let session = WorkSession(
            id: UUID(),
            startTime: Date(),
            endTime: nil,
            activityType: activityType,
            title: title,
            notes: notes,
            status: .active,
            interruptions: 0,
            isFavorite: false
        )
        activeSession = session
        startTicking()
        saveToUserDefaults()
    }

    func pauseSession() {
        guard var s = activeSession else { return }
        s.status = .paused
        activeSession = s
        stopTicking()
        saveToUserDefaults()
    }

    func resumeSession() {
        guard var s = activeSession else { return }
        s.status = .active
        activeSession = s
        startTicking()
        saveToUserDefaults()
    }

    func stopSession() {
        guard var session = activeSession else { return }
        session.endTime = Date()
        session.status = .completed
        sessions.append(session)
        updateGoals(with: Int(session.endTime!.timeIntervalSince(session.startTime)))
        activeSession = nil
        stopTicking()
        saveToUserDefaults()
    }

    private func startTicking() {
        stopTicking()
        tickCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.activeSession != nil else { return }
                self.objectWillChange.send()
            }
    }

    private func stopTicking() {
        tickCancellable?.cancel()
        tickCancellable = nil
    }

    func deleteSession(_ session: WorkSession) {
        sessions.removeAll { $0.id == session.id }
        saveToUserDefaults()
    }

    private func updateGoals(with seconds: Int) {
        let minutesAdded = seconds / 60
        if var goal = dailyGoal, Calendar.current.isDate(goal.date, inSameDayAs: Date()) {
            goal.currentMinutes += minutesAdded
            if goal.currentMinutes >= goal.targetMinutes {
                goal.isCompleted = true
            }
            dailyGoal = goal
        }
        if var goal = weeklyGoal {
            let cal = Calendar.current
            let currentWeekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            if cal.isDate(goal.weekStart, equalTo: currentWeekStart, toGranularity: .weekOfYear) {
                goal.currentMinutes += minutesAdded
                if goal.currentMinutes >= goal.targetMinutes {
                    goal.isCompleted = true
                }
                weeklyGoal = goal
            }
        }
        saveToUserDefaults()
    }

    func setDailyGoal(minutes: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        let current = minutesToday()
        dailyGoal = DailyGoal(
            id: UUID(),
            date: today,
            targetMinutes: minutes,
            currentMinutes: current,
            isCompleted: current >= minutes
        )
        saveToUserDefaults()
    }

    func setWeeklyGoal(minutes: Int) {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let current = minutesLast7Days()
        weeklyGoal = WeeklyGoal(
            id: UUID(),
            weekStart: weekStart,
            targetMinutes: minutes,
            currentMinutes: current,
            isCompleted: current >= minutes
        )
        saveToUserDefaults()
    }

    func addTask(_ task: FocusTask) {
        tasks.append(task)
        saveToUserDefaults()
    }

    func updateTask(_ task: FocusTask) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[i] = task
            saveToUserDefaults()
        }
    }

    func deleteTask(_ task: FocusTask) {
        tasks.removeAll { $0.id == task.id }
        saveToUserDefaults()
    }

    func toggleTaskCompletion(_ task: FocusTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveToUserDefaults()
        }
    }

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
        if let encoded = try? JSONEncoder().encode(dailyGoal) {
            UserDefaults.standard.set(encoded, forKey: dailyGoalKey)
        }
        if let encoded = try? JSONEncoder().encode(weeklyGoal) {
            UserDefaults.standard.set(encoded, forKey: weeklyGoalKey)
        }
        if let encoded = try? JSONEncoder().encode(activeSession) {
            UserDefaults.standard.set(encoded, forKey: activeSessionKey)
        } else {
            UserDefaults.standard.removeObject(forKey: activeSessionKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([WorkSession].self, from: data) {
            sessions = decoded
        }
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([FocusTask].self, from: data) {
            tasks = decoded
        }
        if let data = UserDefaults.standard.data(forKey: dailyGoalKey),
           let decoded = try? JSONDecoder().decode(DailyGoal.self, from: data) {
            dailyGoal = decoded
        }
        if let data = UserDefaults.standard.data(forKey: weeklyGoalKey),
           let decoded = try? JSONDecoder().decode(WeeklyGoal.self, from: data) {
            weeklyGoal = decoded
        }
        if let data = UserDefaults.standard.data(forKey: activeSessionKey),
           let decoded = try? JSONDecoder().decode(WorkSession.self, from: data) {
            activeSession = decoded
            if decoded.status == .active {
                startTicking()
            }
        }
        refreshGoalsForCurrentPeriod()
        if sessions.isEmpty, tasks.isEmpty, dailyGoal == nil {
            loadDemoData()
        }
    }

    func refreshDashboard() {
        refreshGoalsForCurrentPeriod()
    }

    private func refreshGoalsForCurrentPeriod() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        if var dg = dailyGoal {
            if !cal.isDate(dg.date, inSameDayAs: today) {
                let m = minutesToday()
                dg = DailyGoal(
                    id: UUID(),
                    date: today,
                    targetMinutes: dg.targetMinutes,
                    currentMinutes: m,
                    isCompleted: m >= dg.targetMinutes
                )
            } else {
                dg.currentMinutes = minutesToday()
                dg.isCompleted = dg.currentMinutes >= dg.targetMinutes
            }
            dailyGoal = dg
        }
        if var wg = weeklyGoal {
            let currentWeekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            if !cal.isDate(wg.weekStart, equalTo: currentWeekStart, toGranularity: .weekOfYear) {
                let m = minutesLast7Days()
                wg = WeeklyGoal(
                    id: UUID(),
                    weekStart: currentWeekStart,
                    targetMinutes: wg.targetMinutes,
                    currentMinutes: m,
                    isCompleted: m >= wg.targetMinutes
                )
            } else {
                wg.currentMinutes = minutesLast7Days()
                wg.isCompleted = wg.currentMinutes >= wg.targetMinutes
            }
            weeklyGoal = wg
        }
        saveToUserDefaults()
    }

    private func loadDemoData() {
        let session1 = WorkSession(
            id: UUID(),
            startTime: Date().addingTimeInterval(-3600 * 2),
            endTime: Date().addingTimeInterval(-3600),
            activityType: .coding,
            title: "App UI work",
            notes: "SwiftUI screens",
            status: .completed,
            interruptions: 1,
            isFavorite: true
        )
        let session2 = WorkSession(
            id: UUID(),
            startTime: Date().addingTimeInterval(-86400),
            endTime: Date().addingTimeInterval(-86400 + 5400),
            activityType: .reading,
            title: "Professional reading",
            notes: nil,
            status: .completed,
            interruptions: 0,
            isFavorite: false
        )
        sessions = [session1, session2]
        let task = FocusTask(
            id: UUID(),
            title: "Ship notifications module",
            description: nil,
            priority: 4,
            estimatedTime: 120,
            actualTime: 0,
            deadline: Date().addingTimeInterval(86400 * 2),
            isCompleted: false,
            isImportant: true,
            createdAt: Date()
        )
        tasks = [task]
        setDailyGoal(minutes: 120)
        setWeeklyGoal(minutes: 600)
        saveToUserDefaults()
    }
}
