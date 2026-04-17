//
//  DateFormatting.swift
//  127DeepWork
//

import Foundation

private var enUSLocale: Locale { Locale(identifier: "en_US_POSIX") }

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d, yyyy"
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: date)
}

func formattedDateTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, HH:mm"
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: date)
}

func formattedShortDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    formatter.locale = enUSLocale
    return formatter.string(from: date)
}
