//
//  WorkSession.swift
//  127DeepWork
//

import Foundation

struct WorkSession: Identifiable, Codable, Equatable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var activityType: ActivityType
    var title: String
    var notes: String?
    var status: SessionStatus
    var interruptions: Int
    var isFavorite: Bool

    var duration: Int {
        guard let end = endTime else { return 0 }
        return Int(end.timeIntervalSince(startTime))
    }

    func elapsedSeconds(at date: Date = Date()) -> Int {
        Int(date.timeIntervalSince(startTime))
    }

    func formattedDuration(at date: Date = Date()) -> String {
        let seconds = endTime != nil ? duration : elapsedSeconds(at: date)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
