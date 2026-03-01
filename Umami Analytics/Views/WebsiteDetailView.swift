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
    @ObservedObject var viewModel: WebsiteViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                websiteHeader
                periodSelector
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
            }
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

                    VStack(alignment: .leading, spacing: 4) {
                        Text(website.name)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(website.domain)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private var periodSelector: some View {
        HStack {
            Text("Period:")
                .font(.headline)

            Picker("Period", selection: $viewModel.selectedPeriod) {
                Text("Today").tag(StatsPeriod.day)
                Text("This Week").tag(StatsPeriod.week)
                Text("This Month").tag(StatsPeriod.month)
                Text("This Year").tag(StatsPeriod.year)
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedPeriod) { _, newValue in
                viewModel.changePeriod(newValue)
            }
        }
        .padding(.horizontal)
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
                            .foregroundColor(viewModel.selectedDetailTab == tab ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedDetailTab == tab ? Color.accentColor : Color(UIColor.secondarySystemBackground))
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        WebsiteDetailView(viewModel: WebsiteViewModel(shouldStartBackgroundRefresh: false))
    }
}
