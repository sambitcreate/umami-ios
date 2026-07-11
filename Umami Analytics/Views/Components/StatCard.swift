//
//  StatCard.swift
//  Umami Analytics
//
//  Extracted from ContentView.swift
//

import SwiftUI

struct StatCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var title: String
    var value: String
    var icon: String

    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                Spacer()
            }
            .padding(.bottom, 5)

            HStack {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(
                        reduceMotion ? nil : .spring(response: 0.34, dampingFraction: 1),
                        value: value
                    )
                Spacer()
            }

            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
        .umamiCardSurface()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}
