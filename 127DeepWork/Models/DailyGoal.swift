//
//  DailyGoal.swift
//  127DeepWork
//

import Foundation

struct DailyGoal: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var targetMinutes: Int
    var currentMinutes: Int
    var isCompleted: Bool

    var progress: Double {
        guard targetMinutes > 0 else { return 0 }
        return min(Double(currentMinutes) / Double(targetMinutes), 1.0)
    }
}
