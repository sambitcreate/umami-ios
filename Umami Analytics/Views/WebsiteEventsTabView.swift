import SwiftUI
import Charts

struct WebsiteEventsTabView: View {
    @ObservedObject var viewModel: WebsiteViewModel

    @State private var draftSearch = ""

    var body: some View {
        VStack(spacing: 20) {
            if let tabError = viewModel.tabErrors[.events] {
                inlineError(tabError)
            }

            topEventsSection
            eventSeriesSection
            eventDataInspectorSection
            recentEventsSection
        }
        .onAppear {
            draftSearch = viewModel.eventsSearchQuery
        }
    }

    private var topEventsSection: some View {
        let topEvents = viewModel.metricsByDimension[.event] ?? []

        return VStack(alignment: .leading, spacing: 12) {
            Text("Top Events")
                .font(.headline)
                .padding(.horizontal)

            if topEvents.isEmpty {
                Text("No event metrics available")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(topEvents.prefix(8).enumerated()), id: \.offset) { _, item in
                        HStack {
                            Text(item.x)
                                .font(.subheadline)
                                .lineLimit(1)
                            Spacer()
                            Text("\(item.y)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()

                        if item.id != topEvents.prefix(8).last?.id {
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

    private var eventSeriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Event Trend")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.eventSeries.isEmpty {
                Text("No time-series data available")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                Chart(viewModel.eventSeries) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Events", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue)

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Events", point.value)
                    )
                    .foregroundStyle(.blue.opacity(0.2))
                }
                .frame(height: 220)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }

    private var eventDataInspectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Event Data Inspector")
                .font(.headline)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 10) {
                filterMenus

                if !viewModel.eventDataState.availableFields.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Fields")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        ForEach(viewModel.eventDataState.availableFields.prefix(6)) { field in
                            Text(field.displayText)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if !viewModel.eventDataState.stats.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Stats")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        ForEach(viewModel.eventDataState.stats.keys.sorted(), id: \.self) { key in
                            if let metric = viewModel.eventDataState.stats[key] {
                                HStack {
                                    Text(key)
                                    Spacer()
                                    Text("\(metric.value)")
                                        .foregroundColor(.secondary)
                                }
                                .font(.footnote)
                            }
                        }
                    }
                }

                if !viewModel.eventDataState.availableValues.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Values")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        ForEach(viewModel.eventDataState.availableValues.prefix(6)) { value in
                            HStack {
                                Text(value.displayText)
                                    .font(.footnote)
                                Spacer()
                                if let count = value.count {
                                    Text("\(count)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    private var filterMenus: some View {
        VStack(alignment: .leading, spacing: 8) {
            Menu {
                Button("All events") {
                    viewModel.selectEventDataEvent(nil)
                }

                ForEach(viewModel.eventDataState.availableEvents.prefix(30)) { event in
                    Button(event.displayText) {
                        viewModel.selectEventDataEvent(event.value)
                    }
                }
            } label: {
                labelPill(title: "Event", value: viewModel.eventDataState.selectedEvent ?? "All")
            }

            Menu {
                Button("All properties") {
                    viewModel.selectEventDataProperty(nil)
                }

                ForEach(viewModel.eventDataState.availableProperties.prefix(30)) { property in
                    Button(property.displayText) {
                        viewModel.selectEventDataProperty(property.value)
                    }
                }
            } label: {
                labelPill(title: "Property", value: viewModel.eventDataState.selectedProperty ?? "All")
            }
        }
    }

    private var recentEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Events")
                .font(.headline)
                .padding(.horizontal)

            HStack(spacing: 8) {
                TextField("Search events", text: $draftSearch)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        viewModel.applyEventsSearch(draftSearch)
                    }

                Button("Search") {
                    viewModel.applyEventsSearch(draftSearch)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)

            if let page = viewModel.eventsPage, !page.data.isEmpty {
                VStack(spacing: 0) {
                    ForEach(page.data.prefix(20)) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.eventPrimaryText)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            if let subtitle = event.eventSecondaryText {
                                Text(subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }

                            if let metric = event.metricValue {
                                Text("Count: \(metric)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()

                        if event.id != page.data.prefix(20).last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)

                if viewModel.hasMoreEvents {
                    Button {
                        viewModel.loadMoreEvents()
                    } label: {
                        if viewModel.isLoadingMoreEvents {
                            ProgressView()
                        } else {
                            Text("Load More")
                                .fontWeight(.medium)
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 4)
                }
            } else {
                Text("No events available")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
    }

    private func labelPill(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .lineLimit(1)
            Image(systemName: "chevron.down")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(8)
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
