//
//  LoginView.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import SwiftUI
import Combine

struct LoginView: View {
    enum ServerType: Int, CaseIterable, Identifiable {
        case umamiCloud
        case selfHosted

        var id: Int { rawValue }
        var title: String {
            switch self {
            case .umamiCloud: return "Umami.is"
            case .selfHosted: return "Self Hosted"
            }
        }
    }

    @State private var selectedServerType: ServerType = .selfHosted
    @State private var serverURL = ""
    @State private var username = ""
    @State private var password = ""
    @State private var apiKey = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showDebugAlert = false

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var appState: AppState
    @Binding var isAuthenticated: Bool

    var body: some View {
        ZStack {
            // Background color
            (colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Logo and title
                VStack(spacing: 10) {
                    Image(colorScheme == .dark ? "umami-light" : "umami")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .accessibilityLabel("Umami Analytics Logo")

                    Text("Umami Analytics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top, 50)

                // Login form
                VStack(spacing: 20) {
                    // Server type selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Server")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Picker("Server", selection: $selectedServerType) {
                            ForEach(ServerType.allCases) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Server URL field
                    if selectedServerType == .selfHosted {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Server URL")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextField("https://analytics.example.com", text: $serverURL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.URL)
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Server URL")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .opacity(0.5)
                            HStack {
                                Image(systemName: "lock.circle.fill")
                                    .foregroundColor(.blue)
                                    .opacity(0.5)
                                Text("https://cloud.umami.is")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .opacity(0.5)
                            }
                        }
                    }

                    if selectedServerType == .umamiCloud {
                        // API Key field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("API Key")
                                .font(.headline)
                                .foregroundColor(.primary)

                            SecureField("Your Umami API key", text: $apiKey)
                                .textInputAutocapitalization(.never)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            Text("Find this in Umami Cloud > Settings > API Keys")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        // Username field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextField("Email or username", text: $username)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }

                        // Password field
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

                    // Login button
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        } else {
                            Text("Sign In →")
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

                // Debug button (hidden at bottom of screen)
                Button(action: {
                    showDebugAlert = true
                }) {
                    Text("Debug Mode")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .alert(isPresented: $showDebugAlert) {
                    Alert(
                        title: Text("Enable Debug Mode"),
                        message: Text("This will bypass authentication and load mock data for UI testing. Debug mode will be reset when the app is closed."),
                        primaryButton: .default(Text("Enable")) {
                            appState.enableDebugMode()
                        },
                        secondaryButton: .cancel()
                    )
                }

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
        .onAppear {
            // If there's a previously used server URL, pre-select server type
            if let saved = AuthManager.shared.serverURL, !saved.isEmpty {
                if saved.contains("cloud.umami.is") || saved.contains("api.umami.is") || AuthManager.shared.isCloud {
                    selectedServerType = .umamiCloud
                } else {
                    selectedServerType = .selfHosted
                    serverURL = saved
                }
            }
        }
        .onChange(of: selectedServerType) { newValue in
            if newValue == .umamiCloud {
                // Keep a consistent display of the chosen host
                serverURL = "https://cloud.umami.is"
            }
        }
    }

    private var isFormValid: Bool {
        switch selectedServerType {
        case .umamiCloud:
            return !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .selfHosted:
            let hasCreds = !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
            return !serverURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && hasCreds
        }
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        switch selectedServerType {
        case .umamiCloud:
            AuthManager.shared.loginWithAPIKey(apiKey: apiKey.trimmingCharacters(in: .whitespacesAndNewlines)) { result in
                isLoading = false
                switch result {
                case .success(_):
                    isAuthenticated = true
                case .failure(let error):
                    if let authError = error as? AuthError {
                        errorMessage = authError.message
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    showError = true
                }
            }
            return
        case .selfHosted:
            let resolvedServerURL = serverURL.trimmingCharacters(in: .whitespacesAndNewlines)
            AuthManager.shared.login(
                serverURL: resolvedServerURL,
                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            ) { result in
            isLoading = false

            switch result {
            case .success(_):
                isAuthenticated = true
            case .failure(let error):
                if let authError = error as? AuthError {
                    errorMessage = authError.message
                } else {
                    errorMessage = error.localizedDescription
                }
                showError = true
            }
            }
        }
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false))
        .environmentObject(AppState())
}
