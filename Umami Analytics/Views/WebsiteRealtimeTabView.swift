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
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text(activeCount > 0 ? "Traffic is live right now" : "Waiting for live traffic")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var livePagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Pages")
                .font(.headline)
                .padding(.horizontal)

            if let pageviews = snapshot?.pageviews, !pageviews.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(pageviews.prefix(10).enumerated()), id: \.offset) { _, page in
                        HStack {
                            Text(page.url)
                                .font(.subheadline)
                                .lineLimit(1)
                            Spacer()
                            if let title = page.title, !title.isEmpty {
                                Text(title)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding()

                        if page.id != pageviews.prefix(10).last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            } else {
                Text("No active pages")
                    .font(.footnote)
                    .foregroundColor(.secondary)
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
                VStack(spacing: 0) {
                    ForEach(Array(events.prefix(10).enumerated()), id: \.offset) { _, event in
                        HStack {
                            Text(event.name)
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding()

                        if event.id != events.prefix(10).last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            } else {
                Text("No live events")
                    .font(.footnote)
                    .foregroundColor(.secondary)
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
                VStack(spacing: 0) {
                    ForEach(Array(countries.prefix(10).enumerated()), id: \.offset) { _, country in
                        HStack {
                            Text(country.key)
                                .font(.subheadline)
                            Spacer()
                            Text("\(country.value)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()

                        if country.key != countries.prefix(10).last?.key {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            } else {
                Text("No country data")
                    .font(.footnote)
                    .foregroundColor(.secondary)
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
