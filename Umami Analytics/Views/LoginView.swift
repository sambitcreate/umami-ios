//
//  LoginView.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import SwiftUI
import Combine

struct LoginView: View {
    @State private var serverURL = ""
    @State private var username = ""
    @State private var password = ""
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

                // Login form
                VStack(spacing: 20) {
                    // Server URL field
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

                    // Username field
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
                            Text("Sign In")
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
    }

    private var isFormValid: Bool {
        !serverURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        AuthManager.shared.login(
            serverURL: serverURL.trimmingCharacters(in: .whitespacesAndNewlines),
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

#Preview {
    LoginView(isAuthenticated: .constant(false))
        .environmentObject(AppState())
}
