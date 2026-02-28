//
//  StatCard.swift
//  Umami Analytics
//
//  Extracted from ContentView.swift
//

import SwiftUI

struct StatCard: View {
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
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}
