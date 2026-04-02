import SwiftUI

struct WebsiteAudienceTabView: View {
    @ObservedObject var viewModel: WebsiteViewModel

    var body: some View {
        VStack(spacing: 20) {
            if let tabError = viewModel.tabErrors[.audience] {
                inlineError(tabError)
            }

            metricsSection(title: "Top Referrers", dimension: .referrer)
            metricsSection(title: "Browsers", dimension: .browser)
            metricsSection(title: "Operating Systems", dimension: .os)
            metricsSection(title: "Devices", dimension: .device)
            metricsSection(title: "Countries", dimension: .country)
            metricsSection(title: "Top Events", dimension: .event)
        }
    }

    private func metricsSection(title: String, dimension: MetricDimension) -> some View {
        let items = viewModel.metricsByDimension[dimension] ?? []
        let displayItems = Array(items.prefix(8))

        return VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

            if displayItems.isEmpty {
                Text("No data available")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(displayItems.enumerated()), id: \.offset) { index, item in
                        HStack {
                            Text(item.x.isEmpty ? "(empty)" : item.x)
                                .font(.subheadline)
                                .lineLimit(1)

                            Spacer()

                            Text("\(item.y)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.x.isEmpty ? "empty" : item.x), \(item.y)")

                        if index < displayItems.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
            }
        }
    }

    private func inlineError(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .accessibilityHidden(true)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}
