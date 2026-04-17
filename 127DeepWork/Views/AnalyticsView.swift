//
//  AnalyticsView.swift
//  127DeepWork
//

import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var viewModel: DeepWorkViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Analytics")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.deepAccent)
                        .deepHeroTitleShadow()
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top days")
                            .font(.headline)
                            .foregroundColor(.white)
                        if viewModel.topDays.isEmpty {
                            Text("Complete sessions to see trends.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.topDays) { day in
                                HStack {
                                    Text(formattedDate(day.date))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(day.minutes) min")
                                        .foregroundColor(.deepAccent)
                                        .bold()
                                        .shadow(color: Color.deepAccent.opacity(0.35), radius: 4, x: 0, y: 0)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                    .padding(18)
                    .deepElevatedPanel(cornerRadius: 20)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Trends")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack(spacing: 16) {
                            trendMiniCard(
                                caption: "Peak hour",
                                value: String(format: "%02d:00", viewModel.mostProductiveHour)
                            )
                            trendMiniCard(
                                caption: "Best weekday",
                                value: viewModel.mostProductiveDay
                            )
                        }
                    }
                    .padding(18)
                    .deepElevatedPanel(cornerRadius: 20, accentRim: true, glowAccent: false)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommendations")
                            .font(.headline)
                            .foregroundColor(.white)
                        ForEach(viewModel.recommendations, id: \.self) { recommendation in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.deepAccent, Color.deepAccent.opacity(0.55)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: Color.deepAccent.opacity(0.4), radius: 5, x: 0, y: 0)
                                Text(recommendation)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(18)
                    .deepElevatedPanel(cornerRadius: 20)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .deepScreenBackdrop()
            .toolbarBackground(Color.deepBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func trendMiniCard(caption: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(caption)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(.deepAccent)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.deepBackground.opacity(0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.deepAccent.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
    }
}
