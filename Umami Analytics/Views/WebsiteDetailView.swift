//
//  WebsiteDetailView.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import SwiftUI

struct WebsiteDetailView: View {
    @ObservedObject var viewModel: WebsiteViewModel
    @State private var showingPeriodPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with website info
                websiteHeader

                // Period selector
                periodSelector

                // Stats cards
                statsCards

                // Chart
                if let metrics = viewModel.websiteMetrics {
                    AnalyticsChartView(
                        pageviews: metrics.pageviews,
                        visitors: metrics.sessions,
                        period: viewModel.selectedPeriod
                    )
                    .padding(.horizontal)
                } else {
                    AnalyticsChartView(
                        pageviews: [],
                        visitors: [],
                        period: viewModel.selectedPeriod
                    )
                    .padding(.horizontal)
                }

                // Top pages
                if let metrics = viewModel.websiteMetrics, !metrics.pages.isEmpty {
                    topPagesSection(metrics.pages)
                }

                // Top referrers
                if let metrics = viewModel.websiteMetrics, !metrics.referrers.isEmpty {
                    topReferrersSection(metrics.referrers)
                }

                // Browsers and devices
                if let metrics = viewModel.websiteMetrics,
                   !metrics.browsers.isEmpty || !metrics.devices.isEmpty {
                    browsersAndDevicesSection(
                        browsers: metrics.browsers,
                        devices: metrics.devices
                    )
                }

                // Countries
                if let metrics = viewModel.websiteMetrics, !metrics.countries.isEmpty {
                    countriesSection(metrics.countries)
                }

                // Realtime visitors
                if let realtimeData = viewModel.realtimeData {
                    realtimeSection(realtimeData)
                }

                Spacer(minLength: 40)
            }
        }
        .navigationTitle(viewModel.selectedWebsite?.name ?? "Website Details")
        .refreshable {
            if let website = viewModel.selectedWebsite {
                viewModel.loadWebsiteData(website: website)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.systemBackground))
                            .frame(width: 100, height: 100)
                            .shadow(radius: 5)
                    )
            }
        }
        .alert(isPresented: Binding<Bool>(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - UI Components

    private var websiteHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let website = viewModel.selectedWebsite {
                Text(website.name)
                    .font(.title)
                    .fontWeight(.bold)

                Text(website.domain)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: viewModel.selectedPeriod) { newValue in
                viewModel.changePeriod(newValue)
            }
        }
        .padding(.horizontal)
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

    private func topPagesSection(_ pages: [PageMetric]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Pages")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(pages.prefix(5)) { page in
                    HStack {
                        Text(page.title ?? page.url)
                            .font(.subheadline)
                            .lineLimit(1)

                        Spacer()

                        Text("\(page.value)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))

                    if page.id != pages.prefix(5).last?.id {
                        Divider()
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }

    private func topReferrersSection(_ referrers: [ReferrerMetric]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Referrers")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(referrers.prefix(5)) { referrer in
                    HStack {
                        Text(referrer.referrer.isEmpty ? "Direct / None" : referrer.referrer)
                            .font(.subheadline)
                            .lineLimit(1)

                        Spacer()

                        Text("\(referrer.value)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))

                    if referrer.id != referrers.prefix(5).last?.id {
                        Divider()
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }

    private func browsersAndDevicesSection(browsers: [BrowserMetric], devices: [DeviceMetric]) -> some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Browsers")
                    .font(.headline)
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    ForEach(browsers.prefix(3)) { browser in
                        HStack {
                            Text(browser.name)
                                .font(.subheadline)

                            Spacer()

                            Text("\(browser.value)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))

                        if browser.id != browsers.prefix(3).last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Devices")
                    .font(.headline)
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    ForEach(devices.prefix(3)) { device in
                        HStack {
                            Text(device.device)
                                .font(.subheadline)

                            Spacer()

                            Text("\(device.value)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))

                        if device.id != devices.prefix(3).last?.id {
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

    private func countriesSection(_ countries: [CountryMetric]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Countries")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(countries.prefix(5)) { country in
                    HStack {
                        Text(country.name)
                            .font(.subheadline)

                        Spacer()

                        Text("\(country.value)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))

                    if country.id != countries.prefix(5).last?.id {
                        Divider()
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }

    private func realtimeSection(_ realtimeData: RealtimeData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Realtime")
                    .font(.headline)

                Spacer()

                Text("\(realtimeData.sessions) active visitors")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(20)
            }
            .padding(.horizontal)

            if !realtimeData.pageviews.isEmpty {
                VStack(spacing: 0) {
                    ForEach(realtimeData.pageviews.prefix(3)) { pageview in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pageview.title ?? "Unknown Page")
                                    .font(.subheadline)
                                    .lineLimit(1)

                                Text(pageview.url)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text(formatTimestamp(pageview.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))

                        if pageview.id != realtimeData.pageviews.prefix(3).last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            } else {
                Text("No active pageviews")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    // MARK: - Helper Methods

    private func formatTimestamp(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp) / 1000)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationView {
        WebsiteDetailView(viewModel: WebsiteViewModel())
    }
}
