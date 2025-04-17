//
//  AnalyticsChartView.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import SwiftUI
import Charts

struct AnalyticsChartView: View {
    var pageviews: [PageviewMetric]
    var visitors: [SessionMetric]
    var period: StatsPeriod

    @State private var selectedDataPoint: (date: String, pageviews: Int, visitors: Int)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(period.displayName)
                .font(.headline)
                .foregroundColor(.primary)

            if pageviews.isEmpty || visitors.isEmpty {
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
                            Text("Pageviews")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(dataPoint.pageviews)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }

                        VStack(alignment: .trailing) {
                            Text("Visitors")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(dataPoint.visitors)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
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
            if let lastPageview = pageviews.last, let lastVisitor = visitors.last {
                selectedDataPoint = (lastPageview.date, lastPageview.value, lastVisitor.value)
            }
        }
    }

    private var chartView: some View {
        Chart {
            ForEach(pageviews) { item in
                LineMark(
                    x: .value("Date", formatChartDate(item.date)),
                    y: .value("Pageviews", item.value)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Date", formatChartDate(item.date)),
                    y: .value("Pageviews", item.value)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [.blue.opacity(0.3), .blue.opacity(0.01)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }

            ForEach(visitors) { item in
                LineMark(
                    x: .value("Date", formatChartDate(item.date)),
                    y: .value("Visitors", item.value)
                )
                .foregroundStyle(.green)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Date", formatChartDate(item.date)),
                    y: .value("Visitors", item.value)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [.green.opacity(0.3), .green.opacity(0.01)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
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

                                if let pageviewIndex = pageviews.firstIndex(where: { formatChartDate($0.date) == date }),
                                   let visitorIndex = visitors.firstIndex(where: { formatChartDate($0.date) == date }) {

                                    let pageview = pageviews[pageviewIndex]
                                    let visitor = visitors[visitorIndex]

                                    selectedDataPoint = (pageview.date, pageview.value, visitor.value)
                                }
                            }
                    )
            }
        }
        .frame(height: 200)
    }

    private func formatChartDate(_ dateString: String) -> String {
        // This is a simplified version - in a real app, you'd parse the date properly
        // and format it according to the period (hour, day, month, etc.)
        let components = dateString.split(separator: "T").first ?? ""
        return String(components)
    }

    private func formatDate(_ dateString: String) -> String {
        // This is a simplified version - in a real app, you'd parse the date properly
        // and format it according to the period
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        if let date = dateFormatter.date(from: dateString) {
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

        return dateString
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
        .previewLayout(.sizeThatFits)
}
