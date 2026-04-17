//
//  StatCard.swift
//  127DeepWork
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var accent: Color = .deepAccent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accent, accent.opacity(0.65)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
                Text(title)
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            Text(value)
                .foregroundColor(.white)
                .font(.title2)
                .bold()
        }
        .padding()
        .frame(width: 140, alignment: .leading)
        .deepElevatedPanel(cornerRadius: 16, accentRim: false, glowAccent: false, elevation: .floating)
    }
}
