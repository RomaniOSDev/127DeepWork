//
//  GoalCard.swift
//  127DeepWork
//

import SwiftUI

struct GoalCard: View {
    let title: String
    let current: Int
    let target: Int
    let unit: String
    let isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if isCompleted {
                    Text("Done")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.deepAccent.opacity(0.35), Color.deepAccent.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.deepAccent.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .foregroundColor(.deepAccent)
                }
            }

            HStack {
                Text("Progress:")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(current)/\(target) \(unit)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.deepAccent)

                Spacer()

                ProgressView(value: target > 0 ? Double(current) / Double(target) : 0)
                    .tint(.deepAccent)
                    .frame(width: 100, height: 4)
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
        }
        .padding(18)
        .deepElevatedPanel(
            cornerRadius: 20,
            accentRim: isCompleted,
            glowAccent: isCompleted,
            elevation: .floating
        )
    }
}
