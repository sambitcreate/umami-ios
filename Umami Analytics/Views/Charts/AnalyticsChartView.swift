//
//  AnalyticsChartView.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import SwiftUI
import Charts

enum ChartType: String, CaseIterable {
    case pageviews = "Pageviews"
    case visitors = "Visitors"
}

struct AnalyticsChartView: View {
    var pageviews: [TimeSeriesData]
    var visitors: [TimeSeriesData]
    var period: StatsPeriod

    @State private var selectedChartType: ChartType = .pageviews
    @State private var selectedDataPoint: SelectedDataPoint?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(period.displayName)
                .font(.headline)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
            
            // Chart type selector tabs
            HStack(spacing: 4) {
                ForEach(ChartType.allCases, id: \.self) { chartType in
                    Button(action: {
                        selectedChartType = chartType
                        updateSelectedDataPoint()
                    }) {
                        Text(chartType.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(selectedChartType == chartType ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedChartType == chartType ? Color.blue : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.secondarySystemBackground))
            )

            if currentDataSet.isEmpty {
                ChartPlaceholderView()
            } else {
                chartView

                if let dataPoint = selectedDataPoint {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Date")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(formatDate(dataPoint.date))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text(selectedChartType.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(formatValue(dataPoint.value))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(selectedChartType == .pageviews ? .blue : .orange)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .primary.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            updateSelectedDataPoint()
        }
        .onChange(of: selectedChartType) { _ in
            updateSelectedDataPoint()
        }
        .onChange(of: pageviews) { _ in
            updateSelectedDataPoint()
        }
        .onChange(of: visitors) { _ in
            updateSelectedDataPoint()
        }
    }

    private var chartView: some View {
        let dataSet = currentDataSet

        return Chart {
            ForEach(dataSet) { item in
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value(selectedChartType.rawValue, item.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(LinearGradient(
                    colors: gradientColors.opacityGradient,
                    startPoint: .top,
                    endPoint: .bottom
                ))

                LineMark(
                    x: .value("Date", item.date),
                    y: .value(selectedChartType.rawValue, item.value)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(gradientColors.primary)

                if selectedDataPoint?.date == item.date {
                    PointMark(
                        x: .value("Date", item.date),
                        y: .value(selectedChartType.rawValue, item.value)
                    )
                    .symbolSize(80)
                    .foregroundStyle(.white)
                    .annotation(position: .top) {
                        Text(formatValue(item.value))
                            .font(.caption2)
                            .padding(6)
                            .background(gradientColors.primary.opacity(0.9))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }
            }

            if let selectedDataPoint {
                RuleMark(x: .value("Selected", selectedDataPoint.date))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3]))
                    .foregroundStyle(.secondary)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: xAxisDesiredCount)) { value in
                AxisGridLine()
                AxisTick()
                if let dateValue = value.as(Date.self) {
                    AxisValueLabel(ChartFormatters.chartDateFormatter(for: period).string(from: dateValue))
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                AxisTick()
                if let count = value.as(Int.self) {
                    AxisValueLabel(formatValue(count))
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let plotAreaFrame = geometry[proxy.plotAreaFrame]
                                let plotLocation = CGPoint(
                                    x: value.location.x - plotAreaFrame.origin.x,
                                    y: value.location.y - plotAreaFrame.origin.y
                                )

                                guard plotLocation.x >= 0,
                                      plotLocation.x <= plotAreaFrame.size.width,
                                      plotLocation.y >= 0,
                                      plotLocation.y <= plotAreaFrame.size.height,
                                      let date: Date = proxy.value(atX: plotLocation.x) else {
                                    return
                                }

                                guard let nearestPoint = nearestDataPoint(to: date) else { return }
                                selectedDataPoint = SelectedDataPoint(date: nearestPoint.date, value: nearestPoint.value)
                            }
                    )
            }
        }
        .frame(height: 220)
    }

    private func updateSelectedDataPoint() {
        guard let latestPoint = currentDataSet.last else {
            selectedDataPoint = nil
            return
        }

        selectedDataPoint = SelectedDataPoint(date: latestPoint.date, value: latestPoint.value)
    }

    private func nearestDataPoint(to date: Date) -> TimeSeriesData? {
        let data = currentDataSet
        guard !data.isEmpty else { return nil }

        var lowerBound = 0
        var upperBound = data.count

        while lowerBound < upperBound {
            let midpoint = (lowerBound + upperBound) / 2
            if data[midpoint].date < date {
                lowerBound = midpoint + 1
            } else {
                upperBound = midpoint
            }
        }

        if lowerBound == 0 {
            return data[0]
        }

        if lowerBound == data.count {
            return data[data.count - 1]
        }

        let previous = data[lowerBound - 1]
        let next = data[lowerBound]
        return abs(previous.date.timeIntervalSince(date)) <= abs(next.date.timeIntervalSince(date)) ? previous : next
    }

    private var gradientColors: (primary: Color, opacityGradient: [Color]) {
        switch selectedChartType {
        case .pageviews:
            return (.blue, [.blue.opacity(0.45), .blue.opacity(0.1)])
        case .visitors:
            return (.orange, [.orange.opacity(0.5), .orange.opacity(0.15)])
        }
    }

    private var currentDataSet: [TimeSeriesData] {
        selectedChartType == .pageviews ? pageviews : visitors
    }

    private var xAxisDesiredCount: Int {
        switch period {
        case .day:
            return min(max(currentDataSet.count / 3, 4), 8)
        case .week:
            return 7
        case .month:
            return 8
        case .year:
            return 6
        }
    }

    private func formatChartDate(_ date: Date) -> String {
        ChartFormatters.chartDateFormatter(for: period).string(from: date)
    }

    private func formatDate(_ date: Date) -> String {
        ChartFormatters.detailDateFormatter(for: period).string(from: date)
    }

    private func formatValue(_ value: Int) -> String {
        ChartFormatters.decimalNumberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct ChartPlaceholderView: View {
    private let barHeights: [CGFloat] = [42, 78, 56, 92, 64, 86, 50]

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 4) {
                ForEach(Array(barHeights.enumerated()), id: \.offset) { _, height in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 30, height: height)
                }
            }
            .frame(height: 100)
            .padding(.horizontal, 20)

            Text("No data available")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel("No chart data available")
        }
        .frame(height: 200)
    }
}

#Preview {
    let pageviews = (0..<7).map { index -> TimeSeriesData in
        let date = Calendar.current.date(byAdding: .day, value: index, to: Date()) ?? Date()
        return TimeSeriesData(date: date, value: Int.random(in: 120...220))
    }

    let visitors = (0..<7).map { index -> TimeSeriesData in
        let date = Calendar.current.date(byAdding: .day, value: index, to: Date()) ?? Date()
        return TimeSeriesData(date: date, value: Int.random(in: 60...180))
    }

    return AnalyticsChartView(pageviews: pageviews, visitors: visitors, period: .week)
        .padding()
}

private struct SelectedDataPoint {
    let date: Date
    let value: Int
}

private enum ChartFormatters {
    static let decimalNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private static let chartDayFormatter = makeDateFormatter("HH:mm")
    private static let chartMonthFormatter = makeDateFormatter("MMM d")
    private static let chartYearFormatter = makeDateFormatter("MMM yyyy")
    private static let detailDayFormatter = makeDateFormatter("MMM d, h:mm a")
    private static let detailMonthFormatter = makeDateFormatter("EEEE, MMM d")
    private static let detailYearFormatter = makeDateFormatter("MMM yyyy")

    static func chartDateFormatter(for period: StatsPeriod) -> DateFormatter {
        switch period {
        case .day:
            return chartDayFormatter
        case .week, .month:
            return chartMonthFormatter
        case .year:
            return chartYearFormatter
        }
    }

    static func detailDateFormatter(for period: StatsPeriod) -> DateFormatter {
        switch period {
        case .day:
            return detailDayFormatter
        case .week, .month:
            return detailMonthFormatter
        case .year:
            return detailYearFormatter
        }
    }

    private static func makeDateFormatter(_ dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = dateFormat
        return formatter
    }
}
