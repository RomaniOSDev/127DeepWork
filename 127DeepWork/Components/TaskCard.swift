//
//  TaskCard.swift
//  127DeepWork
//

import SwiftUI

struct TaskCard: View {
    let task: FocusTask

    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(
                    task.isCompleted
                        ? LinearGradient(
                            colors: [Color.deepAccent, Color.deepAccent.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        : LinearGradient(colors: [.gray.opacity(0.6), .gray.opacity(0.35)], startPoint: .top, endPoint: .bottom)
                )
                .font(.title2)

            VStack(alignment: .leading) {
                Text(task.title)
                    .foregroundColor(task.isCompleted ? .gray : .white)
                    .font(.headline)
                    .strikethrough(task.isCompleted)

                if let deadline = task.deadline {
                    Text("Due \(formattedShortDate(deadline))")
                        .font(.caption)
                        .foregroundColor(deadline < Date() && !task.isCompleted ? .deepAccent : .gray)
                }

                HStack {
                    Label("\(task.estimatedTime) min", systemImage: "clock")
                        .font(.caption2)
                    Label("\(task.priority)/5", systemImage: "flag.fill")
                        .font(.caption2)
                }
                .foregroundColor(.gray)
            }

            Spacer()

            if task.isImportant {
                Image(systemName: "star.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.deepAccent, Color.deepAccent.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .font(.caption)
                    .shadow(color: Color.deepAccent.opacity(0.45), radius: 4, x: 0, y: 0)
            }
        }
        .padding(14)
        .deepElevatedPanel(cornerRadius: 16, accentRim: task.isImportant && !task.isCompleted, elevation: .soft)
    }
}
