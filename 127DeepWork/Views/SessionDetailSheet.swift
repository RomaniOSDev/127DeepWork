//
//  SessionDetailSheet.swift
//  127DeepWork
//

import SwiftUI

struct SessionDetailSheet: View {
    let session: WorkSession
    @ObservedObject var viewModel: DeepWorkViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.deepAccent.opacity(0.4), Color.deepAccent.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 56, height: 56)
                                    .shadow(color: Color.deepAccent.opacity(0.35), radius: 10, x: 0, y: 4)
                                Image(systemName: session.activityType.icon)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.deepAccent, Color.deepAccent.opacity(0.6)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .font(.title2)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text(session.title)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                Text(session.activityType.rawValue)
                                    .foregroundColor(.gray)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(16)
                        .deepElevatedPanel(cornerRadius: 18)

                        VStack(alignment: .leading, spacing: 10) {
                            Text(formattedDateTime(session.startTime))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            if let end = session.endTime {
                                Text("Ended: \(formattedDateTime(end))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Text("Duration: \(session.formattedDuration())")
                                .foregroundStyle(DeepGradients.accentCTA)
                                .font(.headline)
                                .shadow(color: Color.deepAccent.opacity(0.35), radius: 6, x: 0, y: 0)
                        }
                        .padding(16)
                        .deepElevatedPanel(cornerRadius: 16)

                        if let notes = session.notes, !notes.isEmpty {
                            Text(notes)
                                .foregroundColor(.white)
                                .font(.body)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .deepElevatedPanel(cornerRadius: 16)
                        }

                        Button(role: .destructive) {
                            viewModel.deleteSession(session)
                            dismiss()
                        } label: {
                            Text("Delete session")
                                .font(.headline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(DeepGradients.destructiveFill)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .strokeBorder(Color.red.opacity(0.35), lineWidth: 1)
                                        )
                                )
                                .shadow(color: Color.red.opacity(0.25), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                }
            }
            .deepScreenBackdrop()
            .navigationTitle("Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.deepBackground.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.deepAccent)
                }
            }
        }
    }
}
