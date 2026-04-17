//
//  ActivityType.swift
//  127DeepWork
//

import Foundation

enum ActivityType: String, CaseIterable, Codable {
    case work = "Work"
    case study = "Study"
    case reading = "Reading"
    case coding = "Coding"
    case design = "Design"
    case writing = "Writing"
    case learning = "Learning"
    case other = "Other"

    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .reading: return "book.closed.fill"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .design: return "paintpalette"
        case .writing: return "pencil"
        case .learning: return "graduationcap"
        case .other: return "star.fill"
        }
    }
}
