import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthManager
    @State private var email    = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.kontraBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                // Logo / wordmark
                VStack(spacing: 8) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.kontraAccent)
                    Text("Kontra")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("Loan Servicing Platform")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)

                // Form
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email").font(.caption).foregroundStyle(.secondary)
                        TextField("you@firm.com", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password").font(.caption).foregroundStyle(.secondary)
                        SecureField("••••••••", text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    if let err = errorMessage {
                        Label(err, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.kontraRed)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task { await signIn() }
                    } label: {
                        Group {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.kontraAccent)
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    private func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            try await auth.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
        } catch let err as APIError {
            errorMessage = err.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    LoginView().environmentObject(AuthManager.shared)
}
