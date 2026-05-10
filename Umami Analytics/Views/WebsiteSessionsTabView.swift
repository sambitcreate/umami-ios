import SwiftUI
import Charts

struct WebsiteSessionsTabView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ObservedObject var viewModel: WebsiteViewModel

    @State private var draftSearch = ""

    var body: some View {
        VStack(spacing: 20) {
            if let tabError = viewModel.tabErrors[.sessions] {
                inlineError(tabError)
            }

            sessionDetailSection
            sessionStatsSection
            weeklySessionsSection
            recentSessionsSection
        }
        .onAppear {
            draftSearch = viewModel.sessionsSearchQuery
        }
    }

    private var sessionStatsSection: some View {
        let metrics = viewModel.sessionStats
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }

        return VStack(alignment: .leading, spacing: 12) {
            Text("Session Summary")
                .font(.headline)
                .padding(.horizontal)

            if metrics.isEmpty {
                Text("No session summary available")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                LazyVGrid(columns: sessionSummaryColumns, spacing: 12) {
                    ForEach(Array(metrics.prefix(6)), id: \.key) { key, value in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(key)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("\(value.value)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .monospacedDigit()
                            if let prev = value.prev {
                                Text("Prev: \(prev)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var sessionSummaryColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 12),
            count: dynamicTypeSize.isAccessibilitySize ? 1 : 2
        )
    }

    private var weeklySessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Sessions")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.sessionsWeekly.isEmpty {
                Text("No weekly session data available")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                Chart(viewModel.sessionsWeekly) { point in
                    BarMark(
                        x: .value("Date", point.date),
                        y: .value("Sessions", point.value)
                    )
                    .foregroundStyle(.indigo)
                }
                .frame(height: 220)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(.headline)
                .padding(.horizontal)

            sessionSearchBar
            recentSessionsList
            loadMoreSessionsButton
        }
    }

    private var sessionSearchBar: some View {
        ViewThatFits(in: .horizontal) {
            sessionSearchControls

            VStack(alignment: .leading, spacing: 8) {
                sessionSearchField
                sessionSearchButton
            }
        }
        .padding(.horizontal)
    }

    private var sessionSearchControls: some View {
        HStack(spacing: 8) {
            sessionSearchField
            sessionSearchButton
        }
    }

    private var sessionSearchField: some View {
        TextField("Search sessions", text: $draftSearch)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textFieldStyle(.roundedBorder)
            .onSubmit {
                viewModel.applySessionsSearch(draftSearch)
            }
            .accessibilityLabel("Search sessions")
    }

    private var sessionSearchButton: some View {
        Button("Search") {
            viewModel.applySessionsSearch(draftSearch)
        }
        .buttonStyle(.bordered)
        .controlSize(dynamicTypeSize.isAccessibilitySize ? .regular : .small)
        .accessibilityLabel("Search")
    }

    @ViewBuilder
    private var recentSessionsList: some View {
        if let page = viewModel.sessionsPage, !page.data.isEmpty {
            let displayItems = Array(page.data.prefix(20))
            VStack(spacing: 0) {
                ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, session in
                    sessionRow(session)

                    if index < displayItems.count - 1 {
                        Divider()
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
        } else {
            Text("No sessions available")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var loadMoreSessionsButton: some View {
        if viewModel.hasMoreSessions {
            Button {
                viewModel.loadMoreSessions()
            } label: {
                if viewModel.isLoadingMoreSessions {
                    ProgressView()
                } else {
                    Text("Load More")
                        .fontWeight(.medium)
                }
            }
            .buttonStyle(.bordered)
            .frame(minHeight: 44)
            .accessibilityLabel("Load More")
            .padding(.top, 4)
        }
    }

    private func sessionRow(_ session: AnalyticsRecord) -> some View {
        Button {
            viewModel.loadSessionDetail(sessionId: session.id)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(session.sessionPrimaryText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)

                    Spacer()

                    if viewModel.selectedSessionID == session.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.accentColor)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                if let subtitle = session.sessionSecondaryText {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let metric = session.metricValue {
                    Text("Value: \(metric)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(viewModel.selectedSessionID == session.id ? Color.accentColor.opacity(0.08) : Color.clear)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }

    private var sessionDetailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Detail")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.isLoadingSessionDetail {
                ProgressView()
                    .accessibilityLabel("Loading session details")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            } else if let session = viewModel.selectedSessionRecord {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.sessionPrimaryText)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)

                            if let subtitle = session.sessionSecondaryText {
                                Text(subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .layoutPriority(1)

                        Spacer()

                        if let metric = session.metricValue {
                            Text("\(metric)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .monospacedDigit()
                        }
                    }

                    if !viewModel.selectedSessionActivity.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Activity")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            ForEach(viewModel.selectedSessionActivity.prefix(6)) { activity in
                                Text(activity.eventPrimaryText)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if !viewModel.selectedSessionProperties.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Properties")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            ForEach(viewModel.selectedSessionProperties.keys.sorted(), id: \.self) { key in
                                HStack(alignment: .top, spacing: 12) {
                                    Text(key)
                                        .font(.footnote)
                                        .fontWeight(.medium)
                                        .lineLimit(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .layoutPriority(1)
                                    Spacer()
                                    Text(viewModel.selectedSessionProperties[key]?.displayText ?? "—")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.trailing)
                                        .lineLimit(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            } else if let selectedID = viewModel.selectedSessionID {
                Text("Session \(selectedID) is loading details.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                Text("Select a session to inspect its detail, activity, and properties.")
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}

private extension JSONValue {
    var displayText: String {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            return NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
        case .bool(let value):
            return value ? "true" : "false"
        case .object:
            return "Object"
        case .array:
            return "Array"
        case .null:
            return "null"
        }
    }
}
