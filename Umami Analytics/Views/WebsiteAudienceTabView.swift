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

        return VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

            if items.isEmpty {
                Text("No data available")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(items.prefix(8).enumerated()), id: \.offset) { _, item in
                        HStack {
                            Text(item.x.isEmpty ? "(empty)" : item.x)
                                .font(.subheadline)
                                .lineLimit(1)

                            Spacer()

                            Text("\(item.y)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()

                        if item.id != items.prefix(8).last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }

    private func inlineError(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
