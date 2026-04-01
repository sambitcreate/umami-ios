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

    @Environment(\.colorScheme) var colorScheme
    @Binding var isAuthenticated: Bool

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
                .ignoresSafeArea()

            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Umami Analytics")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Privacy-focused web analytics")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)

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
                                .foregroundColor(.primary)

                            SecureField("umami_live_xxxxx", text: $apiKey)
                                .textContentType(.password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )

                            Text("Your key is available from the Umami Cloud dashboard.")
                                .font(.caption)
                                .foregroundColor(.secondary)
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
                                .foregroundColor(.primary)

                            TextField("https://analytics.example.com", text: $serverURL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }

                        if serverType == .publicShare {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Share ID")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                TextField("share_abcdef", text: $shareID)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )

                                Text("Shared dashboards open in read-only mode.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                TextField("admin", text: $username)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                SecureField("Password", text: $password)
                                    .padding()
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }

                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        } else {
                            Text(serverType == .cloud ? "Connect" : "Sign In")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isLoading || !isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                }
                .padding(.horizontal, 30)

                Spacer()
            }
            .padding(.vertical, 30)
        }
        .alert(isPresented: $showError, content: {
            Alert(
                title: Text("Login Failed"),
                message: Text(errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        })
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
