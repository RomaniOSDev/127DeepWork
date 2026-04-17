//
//  StatsView.swift
//  127DeepWork
//

import Charts
import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: DeepWorkViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Statistics")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.deepAccent)
                        .deepHeroTitleShadow()
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        StatCard(
                            title: "Total time",
                            value: "\(viewModel.totalHours) h",
                            icon: "clock.fill"
                        )
                        StatCard(
                            title: "Sessions",
                            value: "\(viewModel.totalSessions)",
                            icon: "list.bullet"
                        )
                        StatCard(
                            title: "Daily average",
                            value: "\(viewModel.averageDaily) min",
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        StatCard(
                            title: "Completion",
                            value: String(format: "%.0f%%", viewModel.completionRate),
                            icon: "target"
                        )
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Last 7 days")
                            .font(.headline)
                            .foregroundColor(.white)
                        Chart {
                            ForEach(viewModel.weeklyActivity) { data in
                                BarMark(
                                    x: .value("Day", data.day),
                                    y: .value("Minutes", data.minutes)
                                )
                                .foregroundStyle(DeepGradients.barVolume)
                            }
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks { _ in
                                AxisValueLabel()
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .chartYAxis {
                            AxisMarks { _ in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                    .foregroundStyle(Color.white.opacity(0.08))
                                AxisValueLabel()
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                    .padding(18)
                    .deepElevatedPanel(cornerRadius: 20)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity types")
                            .font(.headline)
                            .foregroundColor(.white)
                        ForEach(viewModel.activityDistribution) { item in
                            HStack {
                                Image(systemName: item.icon)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.deepAccent, Color.deepAccent.opacity(0.55)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 30)
                                Text(item.name)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(item.minutes) min")
                                    .foregroundColor(.deepAccent)
                                Text("(\(Int(item.percentage))%)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(18)
                    .deepElevatedPanel(cornerRadius: 20)
                    .padding(.horizontal)

                    productiveHoursSection
                }
                .padding(.vertical)
            }
            .deepScreenBackdrop()
            .toolbarBackground(Color.deepBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var productiveHoursSection: some View {
        let maxMinutes = max(viewModel.productivityByHour.values.max() ?? 1, 1)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Productive hours")
                .font(.headline)
                .foregroundColor(.white)
            ForEach(0..<24, id: \.self) { hour in
                let minutes = viewModel.productivityByHour[hour] ?? 0
                HStack {
                    Text(String(format: "%02d:00", hour))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(width: 45, alignment: .leading)
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(DeepGradients.barVolume)
                        .frame(width: CGFloat(minutes) / CGFloat(maxMinutes) * 200, height: 20)
                        .shadow(color: Color.deepAccent.opacity(minutes > 0 ? 0.35 : 0), radius: 6, x: 0, y: 2)
                    Text("\(minutes) min")
                        .font(.caption)
                        .foregroundColor(.deepAccent)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(18)
        .deepElevatedPanel(cornerRadius: 20)
        .padding(.horizontal)
    }
}
