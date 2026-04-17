//
//  SessionStatus.swift
//  127DeepWork
//

import Foundation

enum SessionStatus: String, Codable {
    case active = "Active"
    case paused = "Paused"
    case completed = "Completed"
    case interrupted = "Interrupted"
}
