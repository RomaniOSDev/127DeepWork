//
//  SessionRow.swift
//  127DeepWork
//

import SwiftUI

struct SessionRow: View {
    let session: WorkSession

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.deepAccent.opacity(0.35), Color.deepAccent.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                Image(systemName: session.activityType.icon)
                    .foregroundColor(.deepAccent)
                    .font(.subheadline.weight(.semibold))
            }

            VStack(alignment: .leading) {
                Text(session.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(formattedDateTime(session.startTime))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(session.formattedDuration())
                .font(.headline)
                .foregroundColor(.deepAccent)
        }
        .padding(12)
        .deepElevatedPanel(cornerRadius: 14, elevation: .soft)
    }
}
