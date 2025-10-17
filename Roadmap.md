# Umami iOS Roadmap

This roadmap consolidates feature opportunities exposed by the Umami Analytics API and maps them to concrete SwiftUI deliverables. Each phase lists:

- **User value** the feature unlocks.
- **Relevant API surface** (see `api.md` for route details).
- **Implementation notes** covering architecture, networking, persistence, and testing.
- **SwiftUI scaffolding** with the components and modifiers to employ.
- **Open design questions** for senior review.

> **Doc sources**: Attempted to fetch the latest upstream documentation via `curl -L https://umami.is/docs/api` but the request was blocked (HTTP 403). Falling back to local `api.md` and existing Umami knowledge for the plan.

## Phase 0 – Foundations & Infrastructure

### 0.1 Authentication & Session Handling
- **API**: `/api/auth/login`, `/api/auth/logout`, `/api/auth/verify`, `/api/me`.
- **Implementation**:
  - Create `AuthService` wrapping login/logout/refresh with `URLSession` and async/await.
  - Securely store the Bearer token in the keychain via `KeychainAccess` or `SecItem` APIs.
  - Implement a centralized `RequestInterceptor` injecting the token and handling 401 retries.
  - Add `AppState` observable object broadcasting authentication changes.
  - Unit test token persistence and 401 recovery flows.
- **SwiftUI scaffold**:
  ```swift
  struct LoginView: View {
      @State private var username = ""
      @State private var password = ""
      @Environment(AuthViewModel.self) private var auth

      var body: some View {
          Form {
              TextField("Email", text: $username)
                  .textContentType(.username)
                  .autocapitalization(.none)
              SecureField("Password", text: $password)
                  .textContentType(.password)
              Button("Sign in") {
                  Task { await auth.login(username: username, password: password) }
              }
              .buttonStyle(.borderedProminent)
              .disabled(auth.isLoading)
          }
          .overlay { if auth.isLoading { ProgressView().controlSize(.large) } }
          .alert(item: $auth.error) { Text($0.message) }
      }
  }
  ```
- **Design questions**: Support SSO now or later? Should biometrics auto-fill credentials?

### 0.2 Networking, Models & Persistence
- **API**: All.
- **Implementation**:
  - Introduce `NetworkClient` with request/response logging (enable via debug toggle).
  - Model responses with `Decodable` structures matching the Umami schema (e.g., `WebsiteSummary`, `TimeSeriesPoint`).
  - Persist frequently accessed datasets (website list, last 7 days stats) using `@AppStorage`, `FileManager`, or SQLite via `GRDB` for offline support.
  - Implement `CachePolicy` enum (networkOnly, cacheFirst, cacheOnly) to drive fetch strategies.
  - Add snapshot tests for decoding correctness.
- **SwiftUI scaffold**:
  ```swift
  @MainActor
  final class WebsiteStore: ObservableObject {
      @Published var websites: [WebsiteSummary] = []
      private let repository: WebsiteRepository

      init(repository: WebsiteRepository) {
          self.repository = repository
      }

      func refresh() async {
          do { websites = try await repository.fetchWebsites() }
          catch { // publish error }
      }
  }
  ```
- **Design questions**: Adopt Combine vs. async sequences? Should caching be per user or per team?

## Phase 1 – Core Dashboard Experience

### 1.1 Multi-Website Overview
- **API**: `/api/me/websites`, `/api/websites/{id}/stats` (currently `stats` is derived via reports endpoints).
- **Implementation**:
  - Build a `DashboardView` listing accessible websites with key metrics (visitors, pageviews, conversion rate).
  - Support pinned/favorite websites stored locally.
  - Provide quick filters (team, search) using `ToolbarItem(placement: .navigationBarTrailing)` segmented control.
- **SwiftUI scaffold**:
  ```swift
  struct DashboardView: View {
      @Environment(WebsiteStore.self) private var store

      var body: some View {
          List(store.websites) { site in
              NavigationLink(value: site) {
                  WebsiteRow(site: site)
              }
          }
          .task { await store.refresh() }
          .navigationDestination(for: WebsiteSummary.self) { WebsiteDetailView(site: $0) }
      }
  }
  ```
- **Design questions**: Represent teams as sections? Support infinite scroll for large accounts?

### 1.2 "Today" & Comparative Time Ranges
- **API**: `/api/websites/{id}/stats`, `/api/reports/retention`, `/api/reports/insights`.
- **Implementation**:
  - Normalize time zones and daylight transitions when grouping `TimeSeriesPoint` data.
  - Offer presets (Today, 7D, 30D, 6M, YTD) with optional custom range picker using `DateIntervalPicker` when available (iOS 17+).
  - Compute deltas vs. previous period.
- **SwiftUI scaffold**:
  ```swift
  struct TimeRangePicker: View {
      @Binding var selection: DateRangePreset

      var body: some View {
          Picker("Range", selection: $selection) {
              ForEach(DateRangePreset.allCases) { preset in
                  Text(preset.label).tag(preset)
              }
          }
          .pickerStyle(.segmented)
      }
  }
  ```
- **Design questions**: Should comparison mode overlay both ranges on the chart?

### 1.3 Charts & Trends
- **API**: `/api/reports/insights` for traffic metrics, `/api/reports/revenue` when e-commerce enabled.
- **Implementation**:
  - Use `Charts` framework with `LineMark`, `AreaMark`, `PointMark` for visitors/pageviews.
  - Provide overlay for conversions when available.
  - Add `ChartPlotAreaBackground` customizing gradient fill.
  - Allow pinch-to-zoom (`ChartXScale(domain:)` with `MagnificationGesture`).
  - Persist user's preferred visualization (line vs area).
- **SwiftUI scaffold**:
  ```swift
  struct TrafficChart: View {
      var series: [TimeSeriesPoint]

      var body: some View {
          Chart(series) { point in
              LineMark(
                  x: .value("Date", point.date),
                  y: .value("Visitors", point.visitors)
              )
              .interpolationMethod(.cardinal)
              AreaMark(
                  x: .value("Date", point.date),
                  y: .value("Pageviews", point.pageviews)
              )
              .foregroundStyle(.blue.gradient.opacity(0.3))
          }
          .chartXAxis { AxisMarks(values: .stride(by: .day)) }
          .chartYAxis { AxisMarks(position: .leading) }
      }
  }
  ```
- **Design questions**: Should we add `RuleMark` for goal annotations? Provide export to PNG?

### 1.4 KPI Cards & Summaries
- **API**: `/api/reports/insights`, `/api/reports/revenue`, `/api/reports/goals`.
- **Implementation**:
  - Create a reusable `MetricCard` component with large primary value, delta indicator, sparkline using `MiniChartView`.
  - Support accessibility: `accessibilityValue` and `accessibilityHint`.
- **SwiftUI scaffold**:
  ```swift
  struct MetricCard: View {
      let metric: Metric

      var body: some View {
          VStack(alignment: .leading, spacing: 8) {
              Text(metric.title).font(.headline)
              Text(metric.formattedValue).font(.system(size: 32, weight: .semibold))
              HStack {
                  Image(systemName: metric.delta >= 0 ? "arrow.up" : "arrow.down")
                  Text(metric.deltaDescription)
              }
              .font(.subheadline)
              .foregroundStyle(metric.delta >= 0 ? .green : .red)
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
      }
  }
  ```
- **Design questions**: Combine metrics into `LazyVGrid` or horizontal scroll on iPhone?

## Phase 2 – Realtime & Live Monitoring

### 2.1 Realtime Visitors Stream
- **API**: `/api/realtime/{websiteId}`.
- **Implementation**:
  - Poll every 5 seconds using `Timer.publish(every:on:in:)` bridged to async sequences.
  - Display active visitors, top pages, locations, referrers.
  - Animate diff updates with `withAnimation` and `AnimatablePair` for counts.
  - Handle connection drop fallback to manual refresh.
- **SwiftUI scaffold**:
  ```swift
  struct RealtimeView: View {
      @State private var snapshot: RealtimeSnapshot?
      @State private var timer: Timer?

      var body: some View {
          List {
              Section("Active Visitors") {
                  Text(snapshot?.activeVisitors.formatted() ?? "--")
                      .font(.largeTitle)
                      .monospacedDigit()
              }
              Section("Top Pages") {
                  ForEach(snapshot?.topPages ?? []) { page in
                      LabeledContent(page.title) { Text(page.visitors.formatted()) }
                  }
              }
          }
          .task { await refresh() }
          .refreshable { await refresh() }
          .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
              Task { await refresh() }
          }
      }

      private func refresh() async { /* call RealtimeRepository */ }
  }
  ```
- **Design questions**: Provide Live Activities for lock screen? Should we throttle on low power mode?

### 2.2 Push Alerts for Spikes & Drops
- **API**: Use reports + custom logic.
- **Implementation**:
  - Allow user-defined thresholds (visitor spike, conversion drop).
  - Schedule background fetch using `BGAppRefreshTask` to evaluate metrics.
  - Trigger local notifications when thresholds breached.
- **SwiftUI scaffold**:
  ```swift
  struct AlertRuleEditor: View {
      @State private var rule = AlertRule.default

      var body: some View {
          Form {
              Picker("Metric", selection: $rule.metric) { /* metrics */ }
              Stepper(value: $rule.threshold, in: 1...10000) {
                  Text("Threshold: \(rule.threshold)")
              }
              Toggle("Notify on decrease", isOn: $rule.triggerOnDrop)
          }
          .navigationTitle("Alert Rule")
      }
  }
  ```
- **Design questions**: Offload to server for reliability? Provide aggregated daily digest emails integration?

## Phase 3 – Deep Analytics

### 3.1 Audience Insights
- **API**: `/api/reports/insights` with dimensions `country`, `device`, `browser`, `os`, `screen`, `language`.
- **Implementation**:
  - Build segmented control to switch between dimension views.
  - Render results via `Chart` (`BarMark`) and tables.
  - Provide filter chips (e.g., include/exclude bots).
- **SwiftUI scaffold**:
  ```swift
  struct DimensionBreakdownView: View {
      let breakdown: [DimensionRow]

      var body: some View {
          Chart(breakdown) { row in
              BarMark(
                  x: .value("Visitors", row.visitors),
                  y: .value("Country", row.label)
              )
              .annotation(position: .trailing) {
                  Text(row.visitors.formatted())
                      .font(.caption)
              }
          }
          .chartYAxis(.hidden)
      }
  }
  ```
- **Design questions**: Persist custom order? Add map visualization for countries?

### 3.2 Referrers & Campaigns
- **API**: `/api/reports/utm`, `/api/reports/insights` with `referrer` dimension.
- **Implementation**:
  - Display session counts, conversions per referrer.
  - Allow deep dive by UTM source/medium/campaign.
  - Integrate search-as-you-type via `.searchable`.
- **SwiftUI scaffold**:
  ```swift
  struct ReferrerListView: View {
      @State private var query = ""
      var rows: [ReferrerRow]

      var body: some View {
          List(filteredRows) { row in
              LabeledContent(row.source) {
                  VStack(alignment: .trailing) {
                      Text("Visitors \(row.visitors)")
                      Text("Conversions \(row.conversions)")
                          .font(.caption)
                          .foregroundStyle(.secondary)
                  }
              }
          }
          .searchable(text: $query)
      }

      private var filteredRows: [ReferrerRow] { /* filter logic */ }
  }
  ```
- **Design questions**: Should we show sparkline per referrer? Provide export as CSV?

### 3.3 Funnels & Journeys
- **API**: `/api/reports/funnel`, `/api/reports/journey`.
- **Implementation**:
  - Create funnel builder UI letting users select ordered steps.
  - Visualize drop-offs with `Chart` stacked bars.
  - Show sample user journeys in timeline view using `ScrollViewReader` for navigation.
- **SwiftUI scaffold**:
  ```swift
  struct FunnelView: View {
      let steps: [FunnelStep]

      var body: some View {
          Chart(steps) { step in
              BarMark(
                  x: .value("Completion", step.rate),
                  y: .value("Step", step.name)
              )
              .foregroundStyle(.teal.gradient)
          }
          .chartXScale(domain: 0...1)
          .chartXAxis { AxisMarks(format: .percent) }
      }
  }
  ```
- **Design questions**: Provide suggestions for next best step? How to anonymize journey data for privacy?

### 3.4 Goals & Conversions
- **API**: `/api/reports/goals`, `/api/reports/revenue`.
- **Implementation**:
  - Allow toggling between macro (sales) and micro (sign-ups) goals.
  - Provide goal comparison chart and cumulative conversion rate line.
  - Support editing/creating goals if the API exposes admin endpoints.
- **SwiftUI scaffold**:
  ```swift
  struct GoalProgressView: View {
      var goals: [GoalMetric]

      var body: some View {
          ScrollView(.horizontal) {
              HStack(spacing: 12) {
                  ForEach(goals) { goal in
                      ProgressView(value: goal.completionRate) {
                          Text(goal.name)
                      } currentValueLabel: {
                          Text(goal.completionRate, format: .percent)
                      }
                      .progressViewStyle(.gauge)
                  }
              }
              .padding(.horizontal)
          }
      }
  }
  ```
- **Design questions**: Should we expose currency switching for revenue? Support forecasting with trend lines?

### 3.5 Retention & Cohorts
- **API**: `/api/reports/retention`.
- **Implementation**:
  - Render retention matrix using custom `Grid` with heatmap colors.
  - Provide toggle for weekly vs monthly cohorts.
  - Offer CSV export.
- **SwiftUI scaffold**:
  ```swift
  struct RetentionHeatmap: View {
      let cohorts: [RetentionCohort]

      var body: some View {
          Grid(alignment: .leading) {
              ForEach(cohorts) { cohort in
                  GridRow {
                      Text(cohort.label)
                      ForEach(cohort.periods) { period in
                          Text(period.rate, format: .percent)
                              .padding(8)
                              .background(RoundedRectangle(cornerRadius: 8).fill(period.color))
                      }
                  }
              }
          }
      }
  }
  ```
- **Design questions**: Use `Color` accessibility-friendly palette? Provide tap-to-highlight cohort details?

## Phase 4 – Management & Collaboration

### 4.1 Website & Team Administration
- **API**: `/api/admin/websites`, `/api/me/teams`, `/api/reports`.
- **Implementation**:
  - Admin-only view listing teams, members, permissions with editing capability.
  - Support creating/editing websites, generating tracking scripts (surface `/api/scripts/telemetry`).
  - Manage sharing links via `/api/share/{shareId}` (view) and admin creation endpoints once available.
- **SwiftUI scaffold**:
  ```swift
  struct TeamManagementView: View {
      @State private var teams: [Team] = []

      var body: some View {
          List {
              ForEach(teams) { team in
                  NavigationLink(team.name) {
                      TeamDetailView(team: team)
                  }
              }
          }
          .toolbar { Button("Add Team", action: presentCreateFlow) }
      }
  }
  ```
- **Design questions**: Gate with role-based access control? Provide audit log view?

### 4.2 Report Builder & Saved Dashboards
- **API**: `/api/reports`, `/api/reports/{reportId}`.
- **Implementation**:
  - Build report creation wizard with drag-and-drop blocks using `ForEach` + `.onMove`.
  - Allow scheduling email exports and push alerts.
  - Persist layout metadata locally for offline viewing.
- **SwiftUI scaffold**:
  ```swift
  struct ReportBuilderView: View {
      @State private var blocks: [ReportBlock] = ReportBlock.defaultBlocks

      var body: some View {
          List {
              ForEach($blocks) { $block in
                  ReportBlockEditor(block: $block)
              }
              .onMove { indices, newOffset in
                  blocks.move(fromOffsets: indices, toOffset: newOffset)
              }
          }
          .toolbar { EditButton() }
      }
  }
  ```
- **Design questions**: Use server-side builder (if API supports) vs local composition? How to sync block ordering between devices?

### 4.3 Sharing & Public Links
- **API**: `/api/share/{shareId}`.
- **Implementation**:
  - Allow scanning QR codes or entering share ID to view public dashboards without login.
  - Provide toggle to keep share link pinned for quick access.
  - Display share metadata (expiration, owner).
- **SwiftUI scaffold**:
  ```swift
  struct ShareAccessView: View {
      @State private var shareId = ""

      var body: some View {
          VStack(spacing: 16) {
              TextField("Share ID", text: $shareId)
                  .textInputAutocapitalization(.never)
                  .textCase(.lowercase)
                  .textFieldStyle(.roundedBorder)
              Button("Open Dashboard") { Task { await openShare() } }
                  .buttonStyle(.borderedProminent)
          }
          .padding()
      }
  }
  ```
- **Design questions**: Support universal links? Should share dashboards be read-only or allow filters?

## Phase 5 – Personalization & Ecosystem

### 5.1 Widgets & Live Activities
- **API**: reuse stats endpoints.
- **Implementation**:
  - Create `WidgetKit` extension with small/medium/large widgets showing visitors today, top page.
  - Integrate Live Activity for real-time visitors using `ActivityConfiguration` on iOS 16.2+.
- **SwiftUI scaffold**:
  ```swift
  struct VisitorsWidgetEntryView: View {
      var entry: VisitorsEntry

      var body: some View {
          VStack(alignment: .leading) {
              Text(entry.websiteName).font(.headline)
              Text(entry.visitorsToday, format: .number)
                  .font(.system(size: 48, weight: .bold))
              Text("Visitors Today")
                  .font(.caption)
                  .foregroundStyle(.secondary)
          }
          .padding()
      }
  }
  ```
- **Design questions**: Provide lock-screen complications for watchOS? Refresh cadence vs widget budget.

### 5.2 Siri Shortcuts & App Intents
- **API**: stats endpoints.
- **Implementation**:
  - Define `AppIntent` for “Show today’s visitors” and “Email weekly report”.
  - Use `INParameter` for selecting websites.
- **SwiftUI scaffold**:
  ```swift
  struct ShowVisitorsIntent: AppIntent {
      static var title: LocalizedStringResource = "Show Visitors"
      @Parameter(title: "Website") var website: WebsiteSummary

      func perform() async throws -> some IntentResult {
          let visitors = try await repository.visitorsToday(for: website.id)
          return .result(value: "\(visitors) visitors today")
      }
  }
  ```
- **Design questions**: Provide custom Siri responses? Support shortcuts for goal conversions?

### 5.3 Apple Watch Companion
- **API**: shared via watch connectivity.
- **Implementation**:
  - Build watchOS app with quick glances for visitors, conversions, top pages.
  - Use `WCSession` to sync metrics.
  - Provide complications using `CLKComplicationTemplate` with daily visitors.
- **SwiftUI scaffold**:
  ```swift
  struct WatchDashboardView: View {
      var snapshot: WebsiteSnapshot

      var body: some View {
          List {
              Section("Visitors") { Text(snapshot.visitorsToday.formatted()) }
              Section("Top Page") { Text(snapshot.topPageTitle) }
          }
      }
  }
  ```
- **Design questions**: Support offline caching on watch? Provide haptics for spikes?

### 5.4 iPad Multitasking & macOS Catalyst
- **API**: shared.
- **Implementation**:
  - Optimize layouts with `NavigationSplitView` for three-column experience.
  - Support keyboard shortcuts via `.commands`.
  - Add drag-and-drop of charts into other apps (export as image or CSV).
- **SwiftUI scaffold**:
  ```swift
  struct AnalyticsSplitView: View {
      @State private var selection: WebsiteSummary?

      var body: some View {
          NavigationSplitView(columnVisibility: .constant(.all)) {
              WebsiteList()
          } detail: {
              if let selection {
                  WebsiteDetailView(site: selection)
              } else {
                  ContentUnavailableView("Select a website", systemImage: "cursorarrow.click")
              }
          }
      }
  }
  ```
- **Design questions**: Provide multi-window support on iPad? Should Catalyst app feel native or mirror iOS layout?

## Phase 6 – Data Governance & Extensibility

### 6.1 Role-Based Access Control
- **API**: `/api/admin/users`, `/api/me/teams`.
- **Implementation**:
  - Expose per-user permissions management UI.
  - Provide invitation flow for new members.
  - Integrate audit log viewer highlighting changes.
- **SwiftUI scaffold**:
  ```swift
  struct RoleAssignmentView: View {
      var body: some View {
          List {
              ForEach(users) { user in
                  Picker("Role", selection: binding(for: user)) {
                      ForEach(Role.allCases) { Text($0.displayName).tag($0) }
                  }
              }
          }
      }
  }
  ```
- **Design questions**: How to expose fine-grained scopes (read vs write)? Provide approval workflow?

### 6.2 Data Export & Integrations
- **API**: `/api/reports` (custom queries), `/api/send`, `/api/batch`.
- **Implementation**:
  - Allow exporting to CSV, JSON, and scheduling S3 uploads.
  - Provide `ShareLink` integration for native share sheet.
  - Build Zapier/webhook triggers using `/api/send` for automation.
- **SwiftUI scaffold**:
  ```swift
  struct ExportSheet: View {
      @Binding var isPresented: Bool

      var body: some View {
          Sheet(isPresented: $isPresented) {
              Form {
                  Picker("Format", selection: $format) { /* CSV, JSON */ }
                  Toggle("Include annotations", isOn: $includeAnnotations)
                  Button("Export") { Task { await performExport() } }
              }
          }
      }
  }
  ```
- **Design questions**: Provide background export progress? Should exports be stored locally?

### 6.3 Custom Events & Client SDK Management
- **API**: `/api/send`, `/api/batch`.
- **Implementation**:
  - Build event tester UI letting users fire custom events to validate tracking setup.
  - Visualize event schema with sample payloads.
  - Provide instructions/snippets for installing Umami tracking script.
- **SwiftUI scaffold**:
  ```swift
  struct EventTesterView: View {
      @State private var eventName = ""
      @State private var payload = "{}"

      var body: some View {
          Form {
              TextField("Event Name", text: $eventName)
              TextEditor(text: $payload)
                  .font(.system(.body, design: .monospaced))
                  .frame(minHeight: 160)
              Button("Send Event") { Task { await sendEvent() } }
                  .buttonStyle(.borderedProminent)
          }
      }
  }
  ```
- **Design questions**: Validate JSON payload locally? Provide sample libraries per platform?

### 6.4 Privacy & Consent Management
- **API**: Integrate with `/api/me` preferences + custom endpoints if available.
- **Implementation**:
  - Allow toggling IP anonymization, Do Not Track compliance, and cookie-less mode.
  - Provide consent log viewer.
  - Surface data retention policies and automatic purge controls.
- **SwiftUI scaffold**:
  ```swift
  struct PrivacySettingsView: View {
      @State private var respectDoNotTrack = true

      var body: some View {
          Form {
              Toggle("Respect Do Not Track", isOn: $respectDoNotTrack)
              Toggle("Anonymize IP", isOn: $anonymizeIP)
              DatePicker("Retention Cutoff", selection: $retentionDate, displayedComponents: .date)
          }
          .navigationTitle("Privacy")
      }
  }
  ```
- **Design questions**: Should consent logs be exportable? How to notify admins about pending requests?

## Phase 7 – Quality & Observability

### 7.1 Automated Testing Strategy
- **Implementation**:
  - Unit tests for repositories using `URLProtocol` stubs.
  - Snapshot tests for SwiftUI views via `ViewInspector` or point-in-time renders.
  - UI tests using `XCTest` UI recorder for login, dashboard navigation, filter application.
  - Integrate CI (GitHub Actions) running `xcodebuild test` with `SIMULATOR_RUNTIME` for latest iOS.
- **SwiftUI scaffold**:
  ```swift
  final class WebsiteRepositoryTests: XCTestCase {
      func testFetchWebsitesDecodesResponse() async throws {
          let client = MockHTTPClient(response: .websites)
          let repository = WebsiteRepository(client: client)
          let sites = try await repository.fetchWebsites()
          XCTAssertEqual(sites.count, 3)
      }
  }
  ```
- **Design questions**: Add contract tests against staging API? Introduce snapshot diffs for charts?

### 7.2 Observability & Logging
- **Implementation**:
  - Centralize logging via `os.Logger` with subsystems (networking, analytics, realtime).
  - Provide in-app diagnostics screen showing recent requests/responses (redacted) and environment metadata.
  - Hook into `MetricKit` for crash/performance data.
- **SwiftUI scaffold**:
  ```swift
  struct DiagnosticsView: View {
      @State private var logs: [LogEntry] = []

      var body: some View {
          List(logs) { log in
              VStack(alignment: .leading) {
                  Text(log.message).font(.body)
                  Text(log.timestamp, style: .time).font(.caption).foregroundStyle(.secondary)
              }
          }
          .toolbar { Button("Share Logs", action: exportLogs) }
      }
  }
  ```
- **Design questions**: Provide remote log upload? Should logs be auto-pruned?

## Appendix – Dependency Considerations
- **Charts**: Native `Charts` framework (iOS 16+). For iOS 15 fallback, consider `SwiftUICharts` or `ChartsCompat` wrappers.
- **Networking**: Prefer `async/await` with `URLSession`. Evaluate `Alamofire` only if interceptors become complex.
- **Image Loading**: Use `AsyncImage` for favicons with caching, or integrate `SDWebImageSwiftUI` if more control needed.
- **App Architecture**: MVVM with `ObservableObject` view models, `@MainActor` enforcement, dependency injection using environment values.
- **Localization**: Structure strings with `StringCatalog` for future translation support.
- **Accessibility**: Support Dynamic Type, VoiceOver hints, and high contrast charts.

## Next Steps for Senior Review
1. Validate phase ordering against business priorities.
2. Confirm required API coverage vs. current backend capabilities.
3. Decide on minimum OS support (iOS 16 vs 17) to finalize SwiftUI/Charts usage.
4. Identify any backend gaps (e.g., admin creation endpoints) requiring upstream work.
5. Approve initial milestone (Phases 0–2) for sprint planning.
