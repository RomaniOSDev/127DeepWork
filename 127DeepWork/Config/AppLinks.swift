//
//  AppLinks.swift
//  127DeepWork
//

import Foundation

/// Legal and external URLs for the app.
enum AppLink: CaseIterable {
    case privacyPolicy
    case termsOfUse

    var string: String {
        switch self {
        case .privacyPolicy:
            return "https://www.termsfeed.com/live/a661cce8-1269-4e75-93d8-8b2e39d94907"
        case .termsOfUse:
            return "https://www.termsfeed.com/live/e46d7acb-27f3-421e-9afe-1ebacee8c8bc"
        }
    }

    var url: URL? {
        URL(string: string)
    }
}
