import SwiftUI
import Charts

struct WebsiteEventsTabView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
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
        let displayItems = Array(topEvents.prefix(8))

        return VStack(alignment: .leading, spacing: 12) {
            Text("Top Events")
                .font(.headline)
                .padding(.horizontal)

            if topEvents.isEmpty {
                Text("No event metrics available")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(displayItems.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 12) {
                            Text(item.x)
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

    private var eventSeriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Event Trend")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.eventSeries.isEmpty {
                Text("No time-series data available")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    private var eventDataInspectorSection: some View {
        let displayFields = Array(viewModel.eventDataState.availableFields.prefix(6))
        let displayValues = Array(viewModel.eventDataState.availableValues.prefix(6))

        return VStack(alignment: .leading, spacing: 12) {
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

                        ForEach(displayFields) { field in
                            Text(field.displayText)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
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
                                HStack(alignment: .top, spacing: 12) {
                                    Text(key)
                                        .lineLimit(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .layoutPriority(1)
                                    Spacer()
                                    Text("\(metric.value)")
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                                .font(.footnote)
                                .accessibilityElement(children: .combine)
                            }
                        }
                    }
                }

                if !viewModel.eventDataState.availableValues.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Values")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        ForEach(displayValues) { value in
                            HStack(alignment: .top, spacing: 12) {
                                Text(value.displayText)
                                    .font(.footnote)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .layoutPriority(1)
                                Spacer()
                                if let count = value.count {
                                    Text("\(count)")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    private var filterMenus: some View {
        let displayEvents = Array(viewModel.eventDataState.availableEvents.prefix(30))
        let displayProperties = Array(viewModel.eventDataState.availableProperties.prefix(30))

        return VStack(alignment: .leading, spacing: 8) {
            Menu {
                Button("All events") {
                    viewModel.selectEventDataEvent(nil)
                }

                ForEach(displayEvents) { event in
                    Button(event.displayText) {
                        viewModel.selectEventDataEvent(event.value)
                    }
                }
            } label: {
                labelPill(title: "Event", value: viewModel.eventDataState.selectedEvent ?? "All")
            }

            Menu {
                Button("All properties") {
                    viewModel.selectEventDataProperty(nil as String?)
                }

                ForEach(displayProperties) { property in
                    Button(property.displayText) {
                        viewModel.selectEventDataProperty(property)
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

            ViewThatFits(in: .horizontal) {
                eventSearchControls

                VStack(alignment: .leading, spacing: 8) {
                    eventSearchField
                    eventSearchButton
                }
            }
            .padding(.horizontal)

            if let page = viewModel.eventsPage, !page.data.isEmpty {
                let displayEvents = Array(page.data.prefix(20))

                VStack(spacing: 0) {
                    ForEach(Array(displayEvents.enumerated()), id: \.offset) { index, event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.eventPrimaryText)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            if let subtitle = event.eventSecondaryText {
                                Text(subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if let metric = event.metricValue {
                                Text("Count: \(metric)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .accessibilityElement(children: .combine)

                        if index < displayEvents.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
                    .frame(minHeight: 44)
                    .accessibilityLabel("Load More")
                    .padding(.top, 4)
                }
            } else {
                Text("No events available")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
    }

    private var eventSearchControls: some View {
        HStack(spacing: 8) {
            eventSearchField
            eventSearchButton
        }
    }

    private var eventSearchField: some View {
        TextField("Search events", text: $draftSearch)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textFieldStyle(.roundedBorder)
            .controlSize(.regular)
            .frame(minHeight: 44)
            .submitLabel(.search)
            .onSubmit {
                viewModel.applyEventsSearch(draftSearch)
            }
            .accessibilityLabel("Search events")
    }

    private var eventSearchButton: some View {
        Button("Search") {
            viewModel.applyEventsSearch(draftSearch)
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
        .frame(minHeight: 44)
        .accessibilityLabel("Search")
    }

    private func labelPill(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Image(systemName: "chevron.down")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(Color(UIColor.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
    }
}
