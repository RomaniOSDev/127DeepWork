//
//  Distraction.swift
//  127DeepWork
//

import Foundation

struct Distraction: Identifiable, Codable, Equatable {
    let id: UUID
    let sessionId: UUID
    let timestamp: Date
    var reason: String
    var duration: Int
}
