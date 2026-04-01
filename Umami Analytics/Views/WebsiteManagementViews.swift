import SwiftUI
import UIKit

@MainActor
struct WebsiteFormView: View {
    enum Mode {
        case create
        case edit(WebsiteModel)

        var title: String {
            switch self {
            case .create:
                return "Add Website"
            case .edit:
                return "Edit Website"
            }
        }

        var actionTitle: String {
            switch self {
            case .create:
                return "Create"
            case .edit:
                return "Save"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    @ObservedObject var viewModel: WebsiteViewModel

    @State private var name: String
    @State private var domain: String
    @State private var shareId: String
    @State private var teamId: String
    @State private var transferTargetID: String
    @State private var isSubmitting = false
    @State private var localError: String?
    @State private var showingResetConfirmation = false

    private var isReadOnlySession: Bool {
        AuthManager.shared.isReadOnlySession
    }

    init(mode: Mode, viewModel: WebsiteViewModel) {
        self.mode = mode
        self.viewModel = viewModel

        switch mode {
        case .create:
            _name = State(initialValue: "")
            _domain = State(initialValue: "")
            _shareId = State(initialValue: "")
            _teamId = State(initialValue: "")
            _transferTargetID = State(initialValue: WorkspaceSelection.personal.id)
        case .edit(let website):
            _name = State(initialValue: website.name)
            _domain = State(initialValue: website.domain)
            _shareId = State(initialValue: website.shareId ?? "")
            _teamId = State(initialValue: website.teamId ?? "")
            _transferTargetID = State(initialValue: website.teamId ?? WorkspaceSelection.personal.id)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                if isReadOnlySession {
                    Section {
                        Label("This session is read-only. Website settings cannot be changed.", systemImage: "lock.fill")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Website Details")) {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .disabled(isSubmitting || isReadOnlySession)

                    TextField("Domain or URL", text: $domain)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .disabled(isSubmitting || isReadOnlySession)
                }

                Section(header: Text("Optional Settings")) {
                    TextField("Share ID", text: $shareId)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(isSubmitting || isReadOnlySession)

                    Button("Generate Share ID") {
                        shareId = String(UUID().uuidString.prefix(12)).lowercased().replacingOccurrences(of: "-", with: "")
                    }
                    .disabled(isSubmitting || isReadOnlySession)

                    if case .create = mode {
                        TextField("Team ID (optional)", text: $teamId)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .disabled(isSubmitting || isReadOnlySession)
                    } else if !teamId.isEmpty {
                        HStack {
                            Text("Team ID")
                            Spacer()
                            Text(teamId)
                                .foregroundColor(.secondary)
                        }
                    }

                    Text("Share IDs let you create public dashboards. Leave blank to skip.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                ownershipSection
                dangerZoneSection

                if let localError {
                    Section {
                        Text(localError)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(action: submit) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text(isReadOnlySession ? "Read Only" : mode.actionTitle)
                        }
                    }
                    .disabled(!canSubmit || isSubmitting || isReadOnlySession)
                }
            }
        }
        .onAppear {
            viewModel.errorMessage = nil
        }
        .confirmationDialog(
            "Reset Analytics",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            if case .edit(let website) = mode {
                Button("Reset Website Data", role: .destructive) {
                    resetWebsite(website)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears collected analytics for the selected website.")
        }
    }

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !domain.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func normalizedDomain(_ value: String) -> String {
        var trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasSuffix("/") {
            trimmed.removeLast()
        }
        return trimmed
    }

    private func normalizedShareId(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed.lowercased()
    }

    private func normalizedTeamId(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func submit() {
        guard canSubmit, !isReadOnlySession else { return }
        localError = nil
        isSubmitting = true

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDomain = normalizedDomain(domain)
        let sanitizedShareId = normalizedShareId(shareId)
        let sanitizedTeamId = normalizedTeamId(teamId)

        switch mode {
        case .create:
            viewModel.createWebsite(name: trimmedName, domain: trimmedDomain, shareId: sanitizedShareId, teamId: sanitizedTeamId) { result in
                handle(result: result)
            }
        case .edit(let website):
            viewModel.updateWebsite(website, name: trimmedName, domain: trimmedDomain, shareId: sanitizedShareId) { result in
                handle(result: result)
            }
        }
    }

    private func handle(result: Result<WebsiteModel, Error>) {
        switch result {
        case .success:
            isSubmitting = false
            dismiss()
        case .failure(let error):
            isSubmitting = false
            let message: String
            if let apiError = error as? APIError {
                message = apiError.message
            } else {
                message = error.localizedDescription
            }
            localError = message
            viewModel.errorMessage = nil
        }
    }

    @ViewBuilder
    private var ownershipSection: some View {
        if case .edit(let website) = mode {
            Section(header: Text("Ownership")) {
                Picker("Transfer To", selection: $transferTargetID) {
                    ForEach(AuthManager.shared.workspaceOptions, id: \.id) { option in
                        Text(option.name).tag(option.id)
                    }
                }
                .disabled(isSubmitting || isReadOnlySession)

                Button("Transfer Website") {
                    transferWebsite(website)
                }
                .disabled(
                    isSubmitting ||
                    isReadOnlySession ||
                    transferTargetID == (website.teamId ?? WorkspaceSelection.personal.id)
                )

                Text("Move this website between your personal workspace and a team.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var dangerZoneSection: some View {
        if case .edit = mode {
            Section(header: Text("Danger Zone")) {
                Button("Reset Analytics", role: .destructive) {
                    showingResetConfirmation = true
                }
                .disabled(isSubmitting || isReadOnlySession)
            }
        }
    }

    private func resetWebsite(_ website: WebsiteModel) {
        isSubmitting = true
        localError = nil

        viewModel.resetWebsite(website) { result in
            switch result {
            case .success:
                isSubmitting = false
                dismiss()
            case .failure(let error):
                isSubmitting = false
                localError = (error as? APIError)?.message ?? error.localizedDescription
                viewModel.errorMessage = nil
            }
        }
    }

    private func transferWebsite(_ website: WebsiteModel) {
        isSubmitting = true
        localError = nil

        let targetTeamId = transferTargetID == WorkspaceSelection.personal.id ? nil : transferTargetID
        viewModel.transferWebsite(website, teamId: targetTeamId) { result in
            switch result {
            case .success:
                isSubmitting = false
                dismiss()
            case .failure(let error):
                isSubmitting = false
                localError = (error as? APIError)?.message ?? error.localizedDescription
                viewModel.errorMessage = nil
            }
        }
    }
}

@MainActor
struct TrackingScriptView: View {
    let website: WebsiteModel

    @Environment(\.dismiss) private var dismiss

    @State private var scriptURL: String
    @State private var includeHostURL = false
    @State private var hostURL: String
    @State private var includeDomains = false
    @State private var allowedDomains = ""
    @State private var disableAutoTrack = false
    @State private var showCopyConfirmation = false

    init(website: WebsiteModel) {
        self.website = website

        let scriptURL = AuthManager.shared.trackerScriptURL()
        let baseURL = AuthManager.shared.currentSession?.trackerBaseURL ?? AuthManager.shared.serverURL ?? ""
        let scriptPath: String
        scriptPath = scriptURL.isEmpty ? "https://your-umami-instance/script.js" : scriptURL

        _scriptURL = State(initialValue: scriptPath)
        _hostURL = State(initialValue: baseURL)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Script Source")) {
                    TextField("Script URL", text: $scriptURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)

                    Text("Update the script location if you are using a CDN or custom domain.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Attributes")) {
                    Toggle("Include data-host-url", isOn: $includeHostURL.animation())

                    if includeHostURL {
                        TextField("Host URL", text: $hostURL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                    }

                    Toggle("Restrict to domains", isOn: $includeDomains.animation())

                    if includeDomains {
                        TextField("Comma-separated domains", text: $allowedDomains)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                        Text("Example: example.com,app.example.com")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    Toggle("Disable automatic tracking", isOn: $disableAutoTrack)
                }

                Section(header: Text("Generated Script")) {
                    TextEditor(text: Binding(
                        get: { scriptSnippet },
                        set: { _ in }
                    ))
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 160)
                        .textSelection(.enabled)

                    Button {
                        copyToClipboard()
                    } label: {
                        Label("Copy to Clipboard", systemImage: "doc.on.doc")
                    }
                }

                Section(header: Text("How to use")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Paste the script inside the <head> of your website.")
                        Text("2. Deploy your site to start collecting analytics.")
                        if includeHostURL {
                            Text("3. Ensure the host URL matches where your API is running.")
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Tracking Script")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Copied!", isPresented: $showCopyConfirmation, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text("The tracking snippet has been copied to your clipboard.")
            })
        }
    }

    private var scriptSnippet: String {
        let trimmedScriptURL = scriptURL.trimmingCharacters(in: .whitespacesAndNewlines)
        var attributes = [
            "async",
            "defer",
            "data-website-id=\"\(website.id)\"",
            "src=\"\(trimmedScriptURL)\""
        ]

        if includeHostURL {
            let trimmed = hostURL.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                attributes.append("data-host-url=\"\(trimmed)\"")
            }
        }

        if includeDomains {
            let trimmed = allowedDomains
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: ",")

            if !trimmed.isEmpty {
                attributes.append("data-domains=\"\(trimmed)\"")
            }
        }

        if disableAutoTrack {
            attributes.append("data-auto-track=\"false\"")
        }

        return "<script \(attributes.joined(separator: " "))></script>"
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = scriptSnippet
        showCopyConfirmation = true
    }
}
