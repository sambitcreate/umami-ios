//
//  LoginView.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import SwiftUI

@MainActor
struct LoginView: View {
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
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)

                    Text("Umami Analytics")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Privacy-focused web analytics")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 50)
                .accessibilityElement(children: .combine)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Server Type")
                            .font(.headline)

                        Picker("Server Type", selection: $serverType) {
                            ForEach(ServerType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    if serverType == .cloud {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Umami Cloud API Key")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            SecureField("umami_live_xxxxx", text: $apiKey)
                                .textContentType(.password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(UIColor.separator), lineWidth: 1)
                                )
                                .accessibilityLabel("API Key")

                            Text("Your key is available from the Umami Cloud dashboard.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cloud Region")
                                .font(.headline)

                            Picker("Cloud Region", selection: $cloudRegion) {
                                ForEach(CloudRegion.allCases) { region in
                                    Text(region.displayName).tag(region)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Server URL")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            TextField("https://analytics.example.com", text: $serverURL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(UIColor.separator), lineWidth: 1)
                                )
                                .accessibilityLabel("Server URL")
                        }

                        if serverType == .publicShare {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Share ID")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                TextField("share_abcdef", text: $shareID)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(UIColor.separator), lineWidth: 1)
                                    )
                                    .accessibilityLabel("Share ID")

                                Text("Shared dashboards open in read-only mode.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                TextField("admin", text: $username)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(UIColor.separator), lineWidth: 1)
                                    )
                                    .accessibilityLabel("Username")
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                SecureField("Password", text: $password)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(UIColor.separator), lineWidth: 1)
                                    )
                                    .accessibilityLabel("Password")
                            }
                        }
                    }

                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .padding()
                                .background(.tint)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Text(serverType == .cloud ? "Connect" : "Sign In")
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .padding()
                                .background(.tint)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .disabled(isLoading || !isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                    .accessibilityLabel(isLoading ? "Signing in" : (serverType == .cloud ? "Connect" : "Sign In"))
                    .accessibilityHint(isFormValid ? "Double tap to sign in" : "Fill in all required fields first")
                }
                .padding(.horizontal, 30)

                Spacer()
            }
            .padding(.vertical, 30)
        }
        .alert("Login Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .onAppear(perform: loadInitialState)
        .onChange(of: serverType) { _, newType in
            AuthManager.shared.setServerType(newType)
            if newType == .selfHosted {
                serverURL = AuthManager.shared.savedSelfHostedServerURL ?? serverURL
            }
        }
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
