import SwiftUI

struct WebsiteRealtimeTabView: View {
    @ObservedObject var viewModel: WebsiteViewModel

    private var snapshot: RealtimeData? {
        viewModel.realtimeSnapshot
    }

    private var activeCount: Int {
        snapshot?.sessions ?? viewModel.activeUsersCount
    }

    private var countries: [(key: String, value: Int)] {
        (snapshot?.countries ?? [:]).sorted { $0.value > $1.value }
    }

    var body: some View {
        VStack(spacing: 20) {
            if let tabError = viewModel.tabErrors[.realtime] {
                inlineError(tabError)
            }

            activeNowCard
            livePagesSection
            liveEventsSection
            liveCountriesSection
        }
    }

    private var activeNowCard: some View {
        VStack(spacing: 10) {
            Text("Active Visitors")
                .font(.headline)

            Text("\(activeCount)")
                .font(.system(.largeTitle, design: .rounded).bold())
                .monospacedDigit()

            Text(activeCount > 0 ? "Traffic is live right now" : "Waiting for live traffic")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .accessibilityLabel("Active visitors: \(activeCount)")
    }

    private var livePagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Pages")
                .font(.headline)
                .padding(.horizontal)

            if let pageviews = snapshot?.pageviews, !pageviews.isEmpty {
                let displayItems = Array(pageviews.prefix(10))
                VStack(spacing: 0) {
                    ForEach(Array(displayItems.enumerated()), id: \.offset) { index, page in
                        HStack {
                            Text(page.url)
                                .font(.subheadline)
                                .lineLimit(1)
                            Spacer()
                            if let title = page.title, !title.isEmpty {
                                Text(title)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding()
                        .accessibilityElement(children: .combine)

                        if index < displayItems.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
            } else {
                Text("No active pages")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
    }

    private var liveEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Events")
                .font(.headline)
                .padding(.horizontal)

            if let events = snapshot?.events, !events.isEmpty {
                let displayItems = Array(events.prefix(10))
                VStack(spacing: 0) {
                    ForEach(Array(displayItems.enumerated()), id: \.offset) { index, event in
                        HStack {
                            Text(event.name)
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding()
                        .accessibilityElement(children: .combine)

                        if index < displayItems.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
            } else {
                Text("No live events")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
    }

    private var liveCountriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Countries")
                .font(.headline)
                .padding(.horizontal)

            if !countries.isEmpty {
                let displayItems = Array(countries.prefix(10))
                VStack(spacing: 0) {
                    ForEach(Array(displayItems.enumerated()), id: \.offset) { index, country in
                        HStack {
                            Text(country.key)
                                .font(.subheadline)
                            Spacer()
                            Text("\(country.value)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .accessibilityElement(children: .combine)

                        if index < displayItems.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
            } else {
                Text("No country data")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
        .accessibilityLabel("Error: \(message)")
        .accessibilityElement(children: .combine)
    }
}
