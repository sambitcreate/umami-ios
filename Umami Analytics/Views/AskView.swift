//
//  AskView.swift
//  Umami Analytics
//

import SwiftUI

@MainActor
struct AskView: View {
    @ObservedObject var websites: WebsiteViewModel
    @StateObject private var ask = AskViewModel()
    @State private var isContextExpanded = false
    @FocusState private var composerIsFocused: Bool

    private var availableWebsites: [WebsiteModel] { websites.filteredWebsites }
    private var selectedWebsite: WebsiteModel? {
        availableWebsites.first { $0.id == ask.selectedWebsiteID }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                contextBar
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            if !ask.availability.isAvailable { availabilityNotice }
                            if let snapshot = ask.snapshot { analyticsContext(snapshot) }
                            if ask.isLoadingData {
                                ProgressView("Loading analytics…")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 24)
                            }
                            if let error = ask.errorMessage { errorNotice(error) }
                            if availableWebsites.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "globe").font(.title2)
                                    Text("No website selected").font(.headline)
                                    Text("Add a website to ask about its analytics.")
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            }
                            if ask.canAsk && ask.messages.isEmpty { emptyConversation }
                            ForEach(ask.messages) { message in messageRow(message) }
                            if ask.isAnswering {
                                Label("Thinking on device…", systemImage: "sparkles")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .accessibilityIdentifier("askThinking")
                            }
                            Color.clear.frame(height: 1).id("askTranscriptBottom")
                        }
                        .frame(maxWidth: 700)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: ask.messages.count) { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            scrollProxy.scrollTo("askTranscriptBottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: ask.isAnswering) { answering in
                        if answering {
                            withAnimation(.easeOut(duration: 0.2)) {
                                scrollProxy.scrollTo("askTranscriptBottom", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ask")
            .navigationBarTitleDisplayMode(.inline)
            .askComposerBar {
                if ask.canAsk {
                    composer
                        .frame(maxWidth: 700)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                }
            }
            .refreshable {
                ask.selectionChanged()
                ask.updateAvailability()
                await ask.loadSnapshot(for: selectedWebsite)
            }
            .onAppear { synchronizeWebsite() }
            .onChange(of: websites.filteredWebsites.map(\.id)) { _ in synchronizeWebsite() }
            .onChange(of: ask.selectedWebsiteID) { _ in reloadSelection() }
            .onChange(of: ask.period) { _ in reloadSelection() }
        }
    }

    private func synchronizeWebsite() {
        if !availableWebsites.contains(where: { $0.id == ask.selectedWebsiteID }) {
            ask.selectedWebsiteID = availableWebsites.first?.id ?? ""
        }
        ask.updateAvailability()
    }

    private func reloadSelection() {
        composerIsFocused = false
        isContextExpanded = false
        ask.selectionChanged()
        Task { await ask.loadSnapshot(for: selectedWebsite) }
    }

    private var contextBar: some View {
        HStack(spacing: 12) {
            if availableWebsites.isEmpty {
                Label("No website selected", systemImage: "globe")
                    .foregroundStyle(.secondary)
            } else {
                Picker("Website", selection: $ask.selectedWebsiteID) {
                    ForEach(availableWebsites) { website in
                        Text(website.name).tag(website.id)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("askWebsitePicker")

                Spacer(minLength: 0)

                Picker("Period", selection: $ask.period) {
                    ForEach(StatsPeriod.allCases, id: \.self) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("askPeriodPicker")
            }
        }
        .font(.subheadline)
        .frame(minHeight: 48)
        .padding(.horizontal, 16)
        .askGlassSurface(cornerRadius: 24)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var availabilityNotice: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(ask.availability.title, systemImage: "info.circle")
                .font(.headline)
            Text(ask.availability.detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .umamiCardSurface(cornerRadius: 18)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("askAvailability")
    }

    private func analyticsContext(_ snapshot: AskAnalyticsSnapshot) -> some View {
        DisclosureGroup(isExpanded: $isContextExpanded) {
            HStack(spacing: 12) {
                stat("Visitors", value: snapshot.stats.visitors.formatted())
                stat("Visits", value: snapshot.stats.visits.formatted())
                stat("Pageviews", value: snapshot.stats.pageviews.formatted())
            }
            .padding(.top, 12)

            Text("Bounce rate \(snapshot.bounceRateText) · Average time per pageview \(snapshot.durationText)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        } label: {
            Label("Analytics context · \(snapshot.period.displayName)", systemImage: "chart.bar.xaxis")
                .font(.subheadline.weight(.medium))
        }
        .padding(14)
        .umamiCardSurface(cornerRadius: 18)
        .accessibilityIdentifier("askSnapshot")
    }

    private func stat(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func errorNotice(_ error: String) -> some View {
        Label(error, systemImage: "exclamationmark.circle")
            .font(.subheadline)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("askError")
    }

    private var emptyConversation: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.tint)
                Text("What would you like to know?")
                    .font(.title3.weight(.semibold))
                Text("Ask about totals, pages, referrers, countries, or events for this period.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ForEach(["Summarize traffic", "Which pages performed best?", "Where did visitors come from?"], id: \.self) { suggestion in
                Button {
                    ask.question = suggestion
                    ask.send()
                } label: {
                    HStack {
                        Text(suggestion)
                        Spacer(minLength: 8)
                        Image(systemName: "arrow.up.left").font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 30)
    }

    private func messageRow(_ message: AskMessage) -> some View {
        HStack(alignment: .top, spacing: 0) {
            if message.isUser { Spacer(minLength: 48) }
            Text(message.text)
                .font(.body)
                .textSelection(.enabled)
                .padding(message.isUser ? 12 : 0)
                .background {
                    if message.isUser {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemFill))
                    }
                }
                .frame(maxWidth: message.isUser ? nil : 620, alignment: .leading)
                .contextMenu {
                    Button("Copy", systemImage: "doc.on.doc") {
                        UIPasteboard.general.string = message.text
                    }
                }
                .accessibilityLabel(message.isUser ? "You: \(message.text)" : "Ask: \(message.text)")
            if !message.isUser { Spacer(minLength: 0) }
        }
        .frame(maxWidth: .infinity)
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Ask about your analytics", text: $ask.question, axis: .vertical)
                .lineLimit(1...6)
                .focused($composerIsFocused)
                .submitLabel(.send)
                .onSubmit { ask.send() }
                .accessibilityIdentifier("askQuestion")
            HStack {
                Label("On-device", systemImage: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if ask.isAnswering {
                    Button {
                        ask.cancelAnswer()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.caption.weight(.bold))
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                            .background(.primary, in: Circle())
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Stop response")
                } else {
                    Button {
                        ask.send()
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.headline.weight(.bold))
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                            .background(.tint, in: Circle())
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .disabled(ask.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Send message")
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 6)
        .askGlassSurface(cornerRadius: 24, interactive: true)
    }
}

private extension StatsPeriod {
    static var allCases: [StatsPeriod] { [.day, .week, .month, .year] }
}

private extension View {
    @ViewBuilder
    func askComposerBar<Bar: View>(@ViewBuilder content: () -> Bar) -> some View {
        if #available(iOS 26.0, *) {
            safeAreaBar(edge: .bottom, spacing: 0, content: content)
        } else {
            safeAreaInset(edge: .bottom, spacing: 0) {
                content().background(.bar)
            }
        }
    }

    @ViewBuilder
    func askGlassSurface(cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                glassEffect(
                    .regular.interactive(),
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
            } else {
                glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
            }
        } else {
            background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
        }
    }
}
