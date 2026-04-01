import Foundation
import Combine

// MARK: - AuthManager
// Manages JWT session state. Token is stored securely in the Keychain.
// OrgId is extracted from the JWT payload's app_metadata.organization_id.

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var accessToken: String?
    @Published var orgId: String?           // Raw integer string e.g. "20"
    @Published var userEmail: String?
    @Published var userRole: String?

    private let tokenKey   = "kontra.access_token"
    private let orgIdKey   = "kontra.org_id"
    private let emailKey   = "kontra.user_email"

    private init() {
        // Restore persisted session on launch
        if let token = KeychainHelper.shared.read(key: tokenKey) {
            self.accessToken = token
            self.orgId       = KeychainHelper.shared.read(key: orgIdKey)
            self.userEmail   = KeychainHelper.shared.read(key: emailKey)
            self.isAuthenticated = true
        }
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws {
        let body = SignInRequest(email: email, password: password)
        let response: SignInResponse = try await APIClient.shared.post("/api/auth/signin", body: body)

        let token = response.accessToken
        let rawOrgId = response.user?.appMetadata?.organizationId ?? extractOrgIdFromJWT(token)
        let email = response.user?.email ?? email

        self.accessToken = token
        self.orgId       = rawOrgId
        self.userEmail   = email
        self.isAuthenticated = true

        KeychainHelper.shared.save(key: tokenKey, value: token)
        KeychainHelper.shared.save(key: orgIdKey,  value: rawOrgId ?? "")
        KeychainHelper.shared.save(key: emailKey,  value: email)
    }

    // MARK: - Sign Out

    func signOut() {
        accessToken  = nil
        orgId        = nil
        userEmail    = nil
        isAuthenticated = false
        KeychainHelper.shared.delete(key: tokenKey)
        KeychainHelper.shared.delete(key: orgIdKey)
        KeychainHelper.shared.delete(key: emailKey)
    }

    // MARK: - JWT decode (extract org_id from payload without a library)

    private func extractOrgIdFromJWT(_ token: String) -> String? {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return nil }
        var payload = parts[1]
        // Base64url → Base64
        payload = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        // Pad to multiple of 4
        let padLen = (4 - payload.count % 4) % 4
        payload += String(repeating: "=", count: padLen)
        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let meta = json["app_metadata"] as? [String: Any],
              let orgId = meta["organization_id"]
        else { return nil }
        return "\(orgId)"
    }
}
