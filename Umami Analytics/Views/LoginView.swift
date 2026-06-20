//
//  LoginView.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import SwiftUI

@MainActor
struct LoginView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var focusedField: LoginField?
    @ScaledMetric(relativeTo: .body) private var horizontalPadding: CGFloat = 30
    @ScaledMetric(relativeTo: .body) private var verticalSpacing: CGFloat = 20

    @State private var serverType: ServerType = AuthManager.shared.serverType
    @State private var serverURL = AuthManager.shared.savedSelfHostedServerURL ?? ""
    @State private var username = ""
    @State private var password = ""
    @State private var apiKey = AuthManager.shared.cloudAPIKey ?? ""
    @State private var shareID = ""
    @State private var cloudRegion: CloudRegion = AuthManager.shared.activeCloudRegion
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false

    @Binding var isAuthenticated: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: dynamicTypeSize.isAccessibilitySize ? 24 : 30) {
                header
                    .padding(.top, dynamicTypeSize.isAccessibilitySize ? 24 : 50)

                formContent
                    .padding(.horizontal, horizontalPadding)

                Spacer(minLength: 24)
            }
            .padding(.vertical, 30)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .alert("Login Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .onAppear(perform: loadInitialState)
        .onChange(of: serverType) { newType in
            AuthManager.shared.setServerType(newType)
            if newType == .selfHosted {
                serverURL = AuthManager.shared.savedSelfHostedServerURL ?? serverURL
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.bar.fill")
                .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                .foregroundStyle(.tint)
                .imageScale(.large)
                .accessibilityHidden(true)

            Text("Umami Analytics")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("Privacy-focused web analytics")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, horizontalPadding)
        .accessibilityElement(children: .combine)
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            pickerSection("Server Type") {
                Picker("Server Type", selection: $serverType) {
                    ForEach(ServerType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
            }

            if serverType == .cloud {
                inputSection(
                    title: "Umami Cloud API Key",
                    help: "Your key is available from the Umami Cloud dashboard."
                ) {
                    SecureField("umami_live_xxxxx", text: $apiKey)
                        .textContentType(.password)
                        .focused($focusedField, equals: .apiKey)
                        .submitLabel(.go)
                        .onSubmit(loginIfPossible)
                        .accessibilityLabel("API Key")
                }

                pickerSection("Cloud Region") {
                    Picker("Cloud Region", selection: $cloudRegion) {
                        ForEach(CloudRegion.allCases) { region in
                            Text(region.displayName).tag(region)
                        }
                    }
                }
            } else {
                inputSection(title: "Server URL") {
                    TextField("https://analytics.example.com", text: $serverURL)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .focused($focusedField, equals: .serverURL)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = serverType == .publicShare ? .shareID : .username
                        }
                        .accessibilityLabel("Server URL")
                }

                if serverType == .publicShare {
                    inputSection(title: "Share ID", help: "Shared dashboards open in read-only mode.") {
                        TextField("share_abcdef", text: $shareID)
                            .focused($focusedField, equals: .shareID)
                            .submitLabel(.go)
                            .onSubmit(loginIfPossible)
                            .accessibilityLabel("Share ID")
                    }
                } else {
                    inputSection(title: "Username") {
                        TextField("admin", text: $username)
                            .textContentType(.username)
                            .focused($focusedField, equals: .username)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                            .accessibilityLabel("Username")
                    }

                    inputSection(title: "Password") {
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit(loginIfPossible)
                            .accessibilityLabel("Password")
                    }
                }
            }

            Button(action: login) {
                ZStack {
                    Text(serverType == .cloud ? "Connect" : "Sign In")
                        .fontWeight(.bold)
                        .opacity(isLoading ? 0 : 1)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.vertical, 12)
                .background(.tint)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(isLoading || !isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            .accessibilityLabel(isLoading ? "Signing in" : (serverType == .cloud ? "Connect" : "Sign In"))
            .accessibilityHint(isFormValid ? "Double tap to sign in" : "Fill in all required fields first")
        }
    }

    private func pickerSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            if dynamicTypeSize.isAccessibilitySize {
                content()
                    .pickerStyle(.menu)
            } else {
                content()
                    .pickerStyle(.segmented)
            }
        }
    }

    private func inputSection<Content: View>(
        title: String,
        help: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            content()
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(UIColor.separator), lineWidth: 1)
                )

            if let help {
                Text(help)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func loginIfPossible() {
        guard isFormValid, !isLoading else { return }
        login()
    }

    private var isFormValid: Bool {
        switch serverType {
        case .cloud:
            return !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .selfHosted:
            return !serverURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !password.isEmpty
        case .publicShare:
            return !serverURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !shareID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private func login() {
        isLoading = true
        errorMessage = nil
        showError = false

        Task { @MainActor in
            defer { isLoading = false }

            do {
                try await AuthManager.shared.login(
                    serverURL: serverType == .selfHosted || serverType == .publicShare ? serverURL : nil,
                    serverType: serverType,
                    username: username,
                    password: password,
                    apiKey: serverType == .cloud ? apiKey : nil,
                    shareID: serverType == .publicShare ? shareID : nil,
                    cloudRegion: cloudRegion
                )
                isAuthenticated = true
            } catch {
                if let authError = error as? AuthError {
                    errorMessage = authError.message
                } else if let apiError = error as? APIError {
                    errorMessage = apiError.message
                } else {
                    errorMessage = error.localizedDescription
                }
                showError = true
            }
        }
    }

    private func loadInitialState() {
        let authManager = AuthManager.shared
        serverType = authManager.serverType
        cloudRegion = authManager.activeCloudRegion
        if serverType == .selfHosted {
            serverURL = authManager.savedSelfHostedServerURL ?? authManager.serverURL ?? ""
        } else if serverType == .publicShare {
            serverURL = authManager.savedPublicShareServerURL ?? authManager.serverURL ?? ""
        } else {
            serverURL = ""
        }
        apiKey = authManager.cloudAPIKey ?? apiKey
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false))
}

private enum LoginField: Hashable {
    case serverURL
    case username
    case password
    case apiKey
    case shareID
}

private extension AuthManager {
    func login(
        serverURL: String?,
        serverType: ServerType,
        username: String?,
        password: String?,
        apiKey: String?,
        shareID: String? = nil,
        cloudRegion: CloudRegion = .global
    ) async throws {
        try await login(
            serverType: serverType,
            serverURL: serverURL,
            username: username,
            password: password,
            apiKey: apiKey,
            shareID: shareID,
            cloudRegion: cloudRegion
        )
    }
}
