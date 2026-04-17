//
//  DeepVisualStyle.swift
//  127DeepWork
//
//  Shared gradients, shadows, and elevated surfaces (palette-only + opacity / black shadow).

import SwiftUI

// MARK: - Gradients

enum DeepGradients {
    static let screenVertical = LinearGradient(
        colors: [
            Color.deepBackground,
            Color.deepBackground,
            Color.deepCard.opacity(0.5)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let screenGlow = RadialGradient(
        colors: [
            Color.deepAccent.opacity(0.18),
            Color.deepAccent.opacity(0.06),
            Color.clear
        ],
        center: .topTrailing,
        startRadius: 40,
        endRadius: 380
    )

    static let screenGlowLeading = RadialGradient(
        colors: [
            Color.deepAccent.opacity(0.1),
            Color.clear
        ],
        center: .leading,
        startRadius: 20,
        endRadius: 280
    )

    /// Card face: depth from corner lighting (stays within palette).
    static let cardFace = LinearGradient(
        colors: [
            Color.deepCard.opacity(1),
            Color.deepCard.opacity(0.88),
            Color.deepBackground.opacity(0.92)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardHighlight = LinearGradient(
        colors: [
            Color.white.opacity(0.16),
            Color.white.opacity(0.04),
            Color.clear
        ],
        startPoint: .top,
        endPoint: UnitPoint(x: 0.5, y: 0.55)
    )

    static let accentRim = LinearGradient(
        colors: [
            Color.deepAccent.opacity(0.55),
            Color.deepAccent.opacity(0.15),
            Color.white.opacity(0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let subtleRim = LinearGradient(
        colors: [
            Color.white.opacity(0.14),
            Color.white.opacity(0.04)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentCTA = LinearGradient(
        colors: [
            Color.deepAccent,
            Color.deepAccent.opacity(0.82),
            Color.deepAccent.opacity(0.58)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let barVolume = LinearGradient(
        colors: [
            Color.deepAccent.opacity(1),
            Color.deepAccent.opacity(0.45)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let destructiveFill = LinearGradient(
        colors: [
            Color.red.opacity(0.45),
            Color.red.opacity(0.22)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Elevation

enum DeepElevation {
    /// Panels, standalone cards
    case floating
    /// List rows, dense lists
    case soft
}

// MARK: - Modifiers

struct DeepElevatedPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var accentRim: Bool = false
    var glowAccent: Bool = false
    var elevation: DeepElevation = .floating

    func body(content: Content) -> some View {
        let stroke: LinearGradient = accentRim ? DeepGradients.accentRim : DeepGradients.subtleRim
        let lineWidth: CGFloat = accentRim ? 1.5 : 1

        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(DeepGradients.cardFace)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(DeepGradients.cardHighlight)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(stroke, lineWidth: lineWidth)
                }
            )
            .shadow(
                color: Color.black.opacity(elevation == .floating ? 0.5 : 0.38),
                radius: elevation == .floating ? 16 : 7,
                x: 0,
                y: elevation == .floating ? 10 : 4
            )
            .shadow(
                color: Color.black.opacity(elevation == .floating ? 0.22 : 0.15),
                radius: elevation == .floating ? 4 : 2,
                x: 0,
                y: elevation == .floating ? 2 : 1
            )
            .shadow(
                color: Color.deepAccent.opacity(glowAccent ? 0.22 : (accentRim ? 0.1 : 0.06)),
                radius: glowAccent ? 20 : 12,
                x: 0,
                y: 5
            )
    }
}

struct DeepPrimaryCTAModifier: ViewModifier {
    var cornerRadius: CGFloat = 22

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(DeepGradients.accentCTA)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.22), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                }
            )
            .shadow(color: Color.deepAccent.opacity(0.5), radius: 18, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

struct DeepScreenBackdropModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    DeepGradients.screenVertical
                    DeepGradients.screenGlow
                    DeepGradients.screenGlowLeading
                }
                .ignoresSafeArea()
            }
    }
}

// MARK: - View extensions

extension View {
    func deepScreenBackdrop() -> some View {
        modifier(DeepScreenBackdropModifier())
    }

    func deepElevatedPanel(
        cornerRadius: CGFloat = 16,
        accentRim: Bool = false,
        glowAccent: Bool = false,
        elevation: DeepElevation = .floating
    ) -> some View {
        modifier(DeepElevatedPanelModifier(
            cornerRadius: cornerRadius,
            accentRim: accentRim,
            glowAccent: glowAccent,
            elevation: elevation
        ))
    }

    func deepPrimaryCTA(cornerRadius: CGFloat = 22) -> some View {
        modifier(DeepPrimaryCTAModifier(cornerRadius: cornerRadius))
    }

    /// Large screen titles (Statistics, Analytics, …)
    func deepHeroTitleShadow() -> some View {
        shadow(color: Color.deepAccent.opacity(0.4), radius: 20, x: 0, y: 0)
            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 4)
    }
}
