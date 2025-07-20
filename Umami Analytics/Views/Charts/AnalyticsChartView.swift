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
    var pageviews: [PageviewMetric]
    var visitors: [SessionMetric]
    var period: StatsPeriod

    @State private var selectedChartType: ChartType = .pageviews
    @State private var selectedDataPoint: (date: String, value: Int)?

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

            if (selectedChartType == .pageviews && pageviews.isEmpty) || (selectedChartType == .visitors && visitors.isEmpty) {
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
                            Text("\(dataPoint.value)")
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
    }

    private var chartView: some View {
        Chart {
            if selectedChartType == .pageviews {
                ForEach(pageviews) { item in
                    if let date = parseDate(item.date) {
                        BarMark(
                            x: .value("Date", date),
                            y: .value("Pageviews", item.value)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.blue, .blue.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(4)
                    }
                }
            } else {
                ForEach(visitors) { item in
                    if let date = parseDate(item.date) {
                        BarMark(
                            x: .value("Date", date),
                            y: .value("Visitors", item.value)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.orange, .orange.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(4)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
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
                                let xPosition = value.location.x

                                guard let date = proxy.value(atX: xPosition, as: String.self) else { return }

                                if selectedChartType == .pageviews {
                                    if let pageviewIndex = pageviews.firstIndex(where: { formatChartDate($0.date) == date }) {
                                        let pageview = pageviews[pageviewIndex]
                                        selectedDataPoint = (pageview.date, pageview.value)
                                    }
                                } else {
                                    if let visitorIndex = visitors.firstIndex(where: { formatChartDate($0.date) == date }) {
                                        let visitor = visitors[visitorIndex]
                                        selectedDataPoint = (visitor.date, visitor.value)
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: 200)
    }

    private func updateSelectedDataPoint() {
        if selectedChartType == .pageviews {
            if let lastPageview = pageviews.last {
                selectedDataPoint = (lastPageview.date, lastPageview.value)
            }
        } else {
            if let lastVisitor = visitors.last {
                selectedDataPoint = (lastVisitor.date, lastVisitor.value)
            }
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        
        // Try different timestamp formats that Umami might use
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
        }
        
        // If it's a Unix timestamp (number as string)
        if let timestamp = Double(dateString) {
            return Date(timeIntervalSince1970: timestamp / 1000) // Convert from milliseconds
        }
        
        return nil
    }
    
    private func formatChartDate(_ dateString: String) -> String {
        guard let date = parseDate(dateString) else {
            return dateString
        }
        
        let dateFormatter = DateFormatter()
        switch period {
        case .day:
            dateFormatter.dateFormat = "HH:mm"
        case .week:
            dateFormatter.dateFormat = "MMM d"
        case .month:
            dateFormatter.dateFormat = "MMM d"
        case .year:
            dateFormatter.dateFormat = "MMM yyyy"
        }
        
        return dateFormatter.string(from: date)
    }

    private func formatDate(_ dateString: String) -> String {
        guard let date = parseDate(dateString) else {
            return dateString
        }
        
        let dateFormatter = DateFormatter()
        switch period {
        case .day:
            dateFormatter.dateFormat = "h:mm a"
        case .week, .month:
            dateFormatter.dateFormat = "MMM d"
        case .year:
            dateFormatter.dateFormat = "MMM yyyy"
        }
        
        return dateFormatter.string(from: date)
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
    let pageviews = [
        PageviewMetric(date: "2023-04-01T00:00:00.000Z", value: 120),
        PageviewMetric(date: "2023-04-02T00:00:00.000Z", value: 145),
        PageviewMetric(date: "2023-04-03T00:00:00.000Z", value: 132),
        PageviewMetric(date: "2023-04-04T00:00:00.000Z", value: 167),
        PageviewMetric(date: "2023-04-05T00:00:00.000Z", value: 189),
        PageviewMetric(date: "2023-04-06T00:00:00.000Z", value: 201),
        PageviewMetric(date: "2023-04-07T00:00:00.000Z", value: 176)
    ]

    let visitors = [
        SessionMetric(date: "2023-04-01T00:00:00.000Z", value: 78),
        SessionMetric(date: "2023-04-02T00:00:00.000Z", value: 92),
        SessionMetric(date: "2023-04-03T00:00:00.000Z", value: 86),
        SessionMetric(date: "2023-04-04T00:00:00.000Z", value: 105),
        SessionMetric(date: "2023-04-05T00:00:00.000Z", value: 118),
        SessionMetric(date: "2023-04-06T00:00:00.000Z", value: 132),
        SessionMetric(date: "2023-04-07T00:00:00.000Z", value: 109)
    ]

    return AnalyticsChartView(pageviews: pageviews, visitors: visitors, period: .week)
        .padding()
}
