//
//  UmamiDesignSystem.swift
//  Umami Analytics
//
//  Shared presentation primitives for responsive, accessible analytics UI.
//

import SwiftUI
import UIKit

enum UmamiDesignMetrics {
    static let cardCornerRadius: CGFloat = 14
    static let compactCornerRadius: CGFloat = 10
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 20
}

struct UmamiCardSurface: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var background: Color = Color(UIColor.secondarySystemGroupedBackground)
    var cornerRadius: CGFloat = UmamiDesignMetrics.cardCornerRadius

    func body(content: Content) -> some View {
        content
            .background(
                reduceTransparency ? Color(UIColor.systemBackground) : background,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay {
                if colorSchemeContrast == .increased || reduceTransparency {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.primary.opacity(colorSchemeContrast == .increased ? 0.28 : 0.12))
                }
            }
    }
}

struct UmamiPressableCardStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(RoundedRectangle(cornerRadius: UmamiDesignMetrics.cardCornerRadius, style: .continuous))
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(
                reduceMotion ? .easeOut(duration: 0.1) : .spring(response: 0.28, dampingFraction: 1),
                value: configuration.isPressed
            )
    }
}

struct UmamiLoadingStatus: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var message: String = "Loading"

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text(message)
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(reduceTransparency ? AnyShapeStyle(Color(UIColor.systemBackground)) : AnyShapeStyle(.regularMaterial))
        .clipShape(Capsule())
        .overlay {
            if reduceTransparency {
                Capsule()
                    .stroke(Color.primary.opacity(0.12))
            }
        }
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
        .onAppear {
            guard UIAccessibility.isVoiceOverRunning else { return }
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
}

extension View {
    func umamiCardSurface(
        background: Color = Color(UIColor.secondarySystemGroupedBackground),
        cornerRadius: CGFloat = UmamiDesignMetrics.cardCornerRadius
    ) -> some View {
        modifier(UmamiCardSurface(background: background, cornerRadius: cornerRadius))
    }
}
