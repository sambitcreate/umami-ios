//
//  WebsiteDetailView.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import SwiftUI

@MainActor
struct WebsiteDetailContainerView: View {
    @StateObject private var viewModel: WebsiteViewModel

    init(website: WebsiteModel) {
        _viewModel = StateObject(
            wrappedValue: WebsiteViewModel(
                shouldStartBackgroundRefresh: false,
                initialWebsite: website
            )
        )
    }

    var body: some View {
        WebsiteDetailView(viewModel: viewModel)
    }
}

@MainActor
struct WebsiteDetailView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ObservedObject var viewModel: WebsiteViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                websiteHeader
                periodSelector
                queryControls
                tabPicker

                currentTabView

                Spacer(minLength: 40)
            }
            .padding(.bottom)
        }
        .navigationTitle(viewModel.selectedWebsite?.name ?? "Website Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.tabLoading[viewModel.selectedDetailTab] == true || viewModel.isRefreshing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .accessibilityLabel("Loading")
                }
            }
        }
        .refreshable {
            viewModel.refreshCurrentTab()
        }
        .alert(
            "Error",
            isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .task {
            if let website = viewModel.selectedWebsite {
                viewModel.loadWebsiteData(website: website)
                viewModel.loadFilterValues()
                viewModel.loadWorkspaceResources()
            }
        }
        .onChange(of: viewModel.selectedPeriod) { _ in
            viewModel.loadFilterValues()
        }
        .onDisappear {
            viewModel.handleDetailDisappear()
        }
    }

    @ViewBuilder
    private var currentTabView: some View {
        switch viewModel.selectedDetailTab {
        case .overview:
            WebsiteOverviewTabView(viewModel: viewModel)
        case .audience:
            WebsiteAudienceTabView(viewModel: viewModel)
        case .events:
            WebsiteEventsTabView(viewModel: viewModel)
        case .sessions:
            WebsiteSessionsTabView(viewModel: viewModel)
        case .realtime:
            WebsiteRealtimeTabView(viewModel: viewModel)
        }
    }

    private var websiteHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let website = viewModel.selectedWebsite {
                HStack(alignment: .center, spacing: 14) {
                    WebsiteFaviconView(domain: website.domain, size: 40)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(website.name)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(website.domain)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(website.name), \(website.domain)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Period")
                .font(.headline)

            if dynamicTypeSize.isAccessibilitySize {
                Menu {
                    periodButtons
                } label: {
                    queryPill(title: "Selected", value: viewModel.selectedPeriod.displayName)
                }
            } else {
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    Text("Today").tag(StatsPeriod.day)
                    Text("This Week").tag(StatsPeriod.week)
                    Text("This Month").tag(StatsPeriod.month)
                    Text("This Year").tag(StatsPeriod.year)
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.selectedPeriod) { newValue in
                    viewModel.changePeriod(newValue)
                }
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var periodButtons: some View {
        Button("Today") { viewModel.changePeriod(.day) }
        Button("This Week") { viewModel.changePeriod(.week) }
        Button("This Month") { viewModel.changePeriod(.month) }
        Button("This Year") { viewModel.changePeriod(.year) }
    }

    private var queryControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            ViewThatFits(in: .horizontal) {
                queryPrimaryControls

                VStack(alignment: .leading, spacing: 10) {
                    queryPrimaryControls
                }
            }

            if !filterMenus.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filterMenus) { menu in
                            Menu {
                                Button("All \(menu.key.displayName.lowercased())") {
                                    viewModel.updateFilter(menu.key, value: nil)
                                }

                                ForEach(menu.values.prefix(12)) { value in
                                    Button(value.displayText) {
                                        viewModel.updateFilter(menu.key, value: value.value)
                                    }
                                }
                            } label: {
                                queryPill(
                                    title: menu.key.displayName,
                                    value: selectedFilterValueText(for: menu.key) ?? "All"
                                )
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            if !viewModel.queryOptions.activeFilters.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.queryOptions.activeFilters, id: \.key) { filter in
                            HStack(spacing: 6) {
                                Text(filter.key.displayName)
                                    .fontWeight(.medium)
                                Text(filter.value)
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(.horizontal)
    }

    private var queryPrimaryControls: some View {
        HStack(spacing: 12) {
            Menu {
                ForEach(AnalyticsComparison.allCases) { comparison in
                    Button(comparison.displayName) {
                        viewModel.updateComparison(comparison)
                    }
                }
            } label: {
                queryPill(title: "Compare", value: viewModel.queryOptions.compare.displayName)
            }

            if viewModel.queryOptions.hasActiveSelections {
                Button("Clear Filters") {
                    viewModel.clearQuerySelections()
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .buttonStyle(.bordered)
                .controlSize(dynamicTypeSize.isAccessibilitySize ? .regular : .small)
            }

            Spacer(minLength: 0)
        }
    }

    private var filterMenus: [QueryMenu] {
        let keys = viewModel.availableFilterValues.keys.sorted { $0.displayName < $1.displayName }

        return keys.compactMap { key in
            guard let values = viewModel.availableFilterValues[key], !values.isEmpty else {
                return nil
            }

            return QueryMenu(key: key, values: values)
        }
    }

    private func selectedFilterValueText(for key: AnalyticsFilterKey) -> String? {
        guard let value = viewModel.queryOptions.filters[key], !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return value
    }

    private func queryPill(title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .fontWeight(.medium)
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(Capsule())
    }

    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(WebsiteDetailTab.allCases) { tab in
                    Button {
                        viewModel.selectDetailTab(tab)
                    } label: {
                        Text(tab.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(viewModel.selectedDetailTab == tab ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedDetailTab == tab ? Color.accentColor : Color(UIColor.secondarySystemBackground))
                            )
                    }
                    .accessibilityLabel(tab.title)
                    .accessibilityAddTraits(viewModel.selectedDetailTab == tab ? .isSelected : [])
                }
            }
            .padding(.horizontal)
        }
        .accessibilityIdentifier("detail-tab-picker")
    }
}

private struct QueryMenu: Identifiable {
    let key: AnalyticsFilterKey
    let values: [FilterValue]

    var id: String { key.rawValue }
}

#Preview {
    NavigationStack {
        WebsiteDetailView(viewModel: WebsiteViewModel(shouldStartBackgroundRefresh: false))
    }
}
