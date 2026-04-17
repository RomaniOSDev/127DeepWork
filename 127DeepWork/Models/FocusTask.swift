//
//  FocusTask.swift
//  127DeepWork
//
//  Named FocusTask to avoid conflict with Swift concurrency Task.

import Foundation

struct FocusTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String?
    var priority: Int
    var estimatedTime: Int
    var actualTime: Int
    var deadline: Date?
    var isCompleted: Bool
    var isImportant: Bool
    let createdAt: Date
}
