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
    @State private var isSubmitting = false
    @State private var localError: String?

    init(mode: Mode, viewModel: WebsiteViewModel) {
        self.mode = mode
        self.viewModel = viewModel

        switch mode {
        case .create:
            _name = State(initialValue: "")
            _domain = State(initialValue: "")
            _shareId = State(initialValue: "")
            _teamId = State(initialValue: "")
        case .edit(let website):
            _name = State(initialValue: website.name)
            _domain = State(initialValue: website.domain)
            _shareId = State(initialValue: website.shareId ?? "")
            _teamId = State(initialValue: website.teamId ?? "")
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Website Details")) {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .disabled(isSubmitting)

                    TextField("Domain or URL", text: $domain)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .disabled(isSubmitting)
                }

                Section(header: Text("Optional Settings")) {
                    TextField("Share ID", text: $shareId)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(isSubmitting)

                    Button("Generate Share ID") {
                        shareId = String(UUID().uuidString.prefix(12)).lowercased().replacingOccurrences(of: "-", with: "")
                    }
                    .disabled(isSubmitting)

                    if case .create = mode {
                        TextField("Team ID (optional)", text: $teamId)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .disabled(isSubmitting)
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
                            Text(mode.actionTitle)
                        }
                    }
                    .disabled(!canSubmit || isSubmitting)
                }
            }
        }
        .onAppear {
            viewModel.errorMessage = nil
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
        guard canSubmit else { return }
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

        let baseURL = AuthManager.shared.serverURL ?? ""
        let scriptPath: String
        if let url = URL(string: baseURL)?.appendingPathComponent("script.js").absoluteString, !baseURL.isEmpty {
            scriptPath = url
        } else if baseURL.isEmpty {
            scriptPath = "https://your-umami-instance/script.js"
        } else {
            let separator = baseURL.hasSuffix("/") ? "" : "/"
            scriptPath = "\(baseURL)\(separator)script.js"
        }

        _scriptURL = State(initialValue: scriptPath)
        _hostURL = State(initialValue: baseURL)
    }

    var body: some View {
        NavigationView {
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
