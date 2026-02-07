import SwiftUI

struct WebsiteOverviewTabView: View {
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
        VStack(spacing: 16) {
            HStack(spacing: 16) {
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
            }

            HStack(spacing: 16) {
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
        }
        .padding(.horizontal)
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
                    Circle()
                        .fill(viewModel.activeUsersCount > 0 ? Color.green : Color.gray)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background((viewModel.activeUsersCount > 0 ? Color.green : Color.gray).opacity(0.1))
                .clipShape(Capsule())
            }
            .padding(.horizontal)

            Text(viewModel.activeUsersCount > 0 ? "These visitors are browsing your site right now." : "We'll update this section as soon as someone arrives on your site.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }

    private func topMetricsSection(title: String, items: [MetricItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

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
