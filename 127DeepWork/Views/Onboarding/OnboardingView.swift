//
//  OnboardingView.swift
//  127DeepWork
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: DeepWorkViewModel
    var onComplete: () -> Void

    @State private var currentPage = 0

    private let pages: [(symbol: String, title: String, detail: String)] = [
        (
            "timer",
            "Run focus sessions",
            "Start a timer, pause when you need a break, and keep a clear history of every focused block."
        ),
        (
            "chart.line.uptrend.xyaxis",
            "Set goals and review progress",
            "Daily and weekly targets keep you consistent. Charts show how your time adds up over days and weeks."
        ),
        (
            "checklist",
            "Organize your tasks",
            "Capture priorities, deadlines, and estimates in one place next to your focus routine."
        )
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Group {
                    DeepGradients.screenVertical
                    DeepGradients.screenGlow
                    DeepGradients.screenGlowLeading
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            finish()
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.deepAccent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, geo.safeAreaInsets.top + 4)
                    .padding(.bottom, 2)

                    TabView(selection: $currentPage) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            onboardingPage(
                                symbol: page.symbol,
                                title: page.title,
                                detail: page.detail
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    pageIndicators

                    VStack(spacing: 6) {
                        if currentPage < pages.count - 1 {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    currentPage += 1
                                }
                            } label: {
                                Text("Next")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(.deepBackground)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .deepPrimaryCTA(cornerRadius: 18)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button {
                                finish()
                            } label: {
                                Text("Get started")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(.deepBackground)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .deepPrimaryCTA(cornerRadius: 18)
                            }
                            .buttonStyle(.plain)
                        }

                        if currentPage > 0 {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    currentPage -= 1
                                }
                            } label: {
                                Text("Back")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, max(geo.safeAreaInsets.bottom, 10))
                }
            }
        }
        .ignoresSafeArea()
    }

    private var pageIndicators: some View {
        HStack(spacing: 10) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.deepAccent : Color.white.opacity(0.22))
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.78), value: currentPage)
            }
        }
        .padding(.vertical, 4)
    }

    private func onboardingPage(symbol: String, title: String, detail: String) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.deepAccent.opacity(0.35),
                                Color.deepAccent.opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 16,
                            endRadius: 88
                        )
                    )
                    .frame(width: 130, height: 130)
                    .shadow(color: Color.deepAccent.opacity(0.22), radius: 16, x: 0, y: 6)

                Image(systemName: symbol)
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.deepAccent, Color.deepAccent.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .deepElevatedPanel(cornerRadius: 18, accentRim: true, glowAccent: false, elevation: .floating)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 2)
    }

    private func finish() {
        viewModel.loadFromUserDefaults()
        onComplete()
    }
}

#Preview {
    OnboardingView(viewModel: DeepWorkViewModel(), onComplete: {})
}
