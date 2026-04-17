//
//  WeeklyGoal.swift
//  127DeepWork
//

import Foundation

struct WeeklyGoal: Identifiable, Codable, Equatable {
    let id: UUID
    var weekStart: Date
    var targetMinutes: Int
    var currentMinutes: Int
    var isCompleted: Bool
}
