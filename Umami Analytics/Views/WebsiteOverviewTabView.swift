import SwiftUI

struct WebsiteOverviewTabView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ObservedObject var viewModel: WebsiteViewModel

    private var topPages: [MetricItem] {
        if let urls = viewModel.metricsByDimension[.url], !urls.isEmpty {
            return urls
        }
        return viewModel.websiteMetrics ?? []
    }

    var body: some View {
        VStack(spacing: 20) {
            if let tabError = viewModel.tabErrors[.overview] {
                inlineError(tabError)
            }

            statsCards

            if let pageviewsData = viewModel.pageviewsData {
                AnalyticsChartView(
                    pageviews: pageviewsData.pageviews,
                    visitors: pageviewsData.sessions,
                    period: viewModel.selectedPeriod
                )
                .padding(.horizontal)
            }

            if !topPages.isEmpty {
                topMetricsSection(title: "Top Pages", items: topPages)
            }

            activeUsersSection
        }
    }

    private var statsCards: some View {
        LazyVGrid(columns: statColumns, spacing: 12) {
            StatCard(
                title: "Visitors",
                value: viewModel.formattedVisitors,
                icon: "person.fill"
            )

            StatCard(
                title: "Pageviews",
                value: viewModel.formattedPageviews,
                icon: "doc.text.fill"
            )

            StatCard(
                title: "Bounce Rate",
                value: viewModel.formattedBounceRate,
                icon: "arrow.up.arrow.down"
            )

            StatCard(
                title: "Avg. Duration",
                value: viewModel.formattedDuration,
                icon: "clock.fill"
            )
        }
        .padding(.horizontal)
    }

    private var statColumns: [GridItem] {
        if dynamicTypeSize >= .xxLarge {
            return [GridItem(.flexible())]
        }

        return [GridItem(.adaptive(minimum: 150), spacing: 12)]
    }

    private var activeUsersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("Active Visitors")
                    .font(.headline)

                Spacer()

                Label {
                    Text(viewModel.activeUsersCount > 0 ? "\(viewModel.activeUsersCount) online now" : "No active visitors")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: viewModel.activeUsersCount > 0 ? "circle.fill" : "circle")
                        .font(.caption2)
                        .foregroundStyle(viewModel.activeUsersCount > 0 ? .green : .secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background((viewModel.activeUsersCount > 0 ? Color.green : Color.gray).opacity(0.1))
                .clipShape(Capsule())
                .accessibilityLabel(viewModel.activeUsersCount > 0 ? "\(viewModel.activeUsersCount) visitors online now" : "No active visitors")
            }
            .padding(.horizontal)

            Text(viewModel.activeUsersCount > 0 ? "These visitors are browsing your site right now." : "We'll update this section as soon as someone arrives on your site.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }

    private func topMetricsSection(title: String, items: [MetricItem]) -> some View {
        let displayItems = Array(items.prefix(8))
        return VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(Array(displayItems.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 12) {
                        Text(item.x.isEmpty ? "(empty)" : item.x)
                            .font(.subheadline)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)

                        Spacer()

                        Text("\(item.y)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    .padding()
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(item.x.isEmpty ? "empty" : item.x), \(item.y) views")

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
