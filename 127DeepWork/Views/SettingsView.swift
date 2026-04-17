//
//  SettingsView.swift
//  127DeepWork
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        settingsRow(
                            title: "Rate us",
                            systemImage: "star.fill",
                            action: rateApp
                        )
                        settingsRow(
                            title: "Privacy Policy",
                            systemImage: "hand.raised.fill",
                            action: openPrivacyPolicy
                        )
                        settingsRow(
                            title: "Terms of Use",
                            systemImage: "doc.text.fill",
                            action: openTermsOfUse
                        )
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.deepCard.opacity(0.65))
                            .padding(.vertical, 2)
                    )
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .deepScreenBackdrop()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.deepBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func settingsRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.deepAccent, Color.deepAccent.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 28, alignment: .center)
                Text(title)
                    .foregroundColor(.white)
                    .font(.body.weight(.medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.gray.opacity(0.8))
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: AppLink.privacyPolicy.string) {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfUse() {
        if let url = URL(string: AppLink.termsOfUse.string) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    SettingsView()
}
