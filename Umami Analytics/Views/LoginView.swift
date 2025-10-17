//
//  LoginView.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import SwiftUI

struct LoginView: View {
    @State private var serverType: ServerType = AuthManager.shared.serverType
    @State private var serverURL = AuthManager.shared.savedSelfHostedServerURL ?? ""
    @State private var username = ""
    @State private var password = ""
    @State private var apiKey = AuthManager.shared.cloudAPIKey ?? ""
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
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    if serverType == .cloud {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Umami Cloud API Key")
                                .font(.headline)
                                .foregroundColor(.primary)

                            SecureField("umami_live_xxxxx", text: $apiKey)
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
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
                    } else {
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

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextField("admin", text: $username)
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
        .onChange(of: serverType) { newType in
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
        }
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        AuthManager.shared.login(
            serverType: serverType,
            serverURL: serverType == .selfHosted ? serverURL : nil,
            username: username,
            password: password,
            apiKey: serverType == .cloud ? apiKey : nil
        ) { result in
            isLoading = false

            switch result {
            case .success:
                isAuthenticated = true
            case .failure(let error):
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
        if serverType == .selfHosted {
            serverURL = authManager.savedSelfHostedServerURL ?? authManager.serverURL ?? ""
        } else {
            serverURL = ""
        }
        apiKey = authManager.cloudAPIKey ?? apiKey
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false))
}
