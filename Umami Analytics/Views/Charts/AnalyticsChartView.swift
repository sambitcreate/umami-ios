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
                .foregroundColor(.primary)
            
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
                            .foregroundColor(selectedChartType == chartType ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedChartType == chartType ? Color.blue : Color.clear)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
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
                                .foregroundColor(.secondary)
                            Text(formatDate(dataPoint.date))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text(selectedChartType.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatValue(dataPoint.value))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedChartType == .pageviews ? .blue : .orange)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            updateSelectedDataPoint()
        }
        .onChange(of: selectedChartType) { _, _ in
            updateSelectedDataPoint()
        }
        .onChange(of: pageviews) { _, _ in
            updateSelectedDataPoint()
        }
        .onChange(of: visitors) { _, _ in
            updateSelectedDataPoint()
        }
    }

    private var chartView: some View {
        Chart {
            ForEach(currentDataSet) { item in
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
                            .foregroundColor(.white)
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
                    AxisValueLabel(formatChartDate(dateValue))
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
                                guard let plotFrame = proxy.plotFrame else {
                                    return
                                }

                                let resolvedFrame = geometry[plotFrame]
                                let originX = resolvedFrame.origin.x
                                let locationX = value.location.x - originX

                                guard locationX >= 0,
                                      locationX <= resolvedFrame.size.width,
                                      let date: Date = proxy.value(atX: value.location.x) else {
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
        return data.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
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
        let formatter = DateFormatter()
        formatter.locale = Locale.current

        switch period {
        case .day:
            formatter.dateFormat = "HH:mm"
        case .week, .month:
            formatter.dateFormat = "MMM d"
        case .year:
            formatter.dateFormat = "MMM yyyy"
        }

        return formatter.string(from: date)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current

        switch period {
        case .day:
            formatter.dateFormat = "MMM d, h:mm a"
        case .week, .month:
            formatter.dateFormat = "EEEE, MMM d"
        case .year:
            formatter.dateFormat = "MMM yyyy"
        }

        return formatter.string(from: date)
    }

    private func formatValue(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct ChartPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 30, height: CGFloat.random(in: 30...100))
                }
            }
            .frame(height: 100)
            .padding(.horizontal, 20)

            Text("No data available")
                .font(.caption)
                .foregroundColor(.secondary)
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
