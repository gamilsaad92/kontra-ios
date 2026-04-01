import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var auth: AuthManager
    @State private var showSignOutConfirm = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("Account") {
                if let email = auth.userEmail {
                    LabeledContent("Email", value: email)
                }
                if let orgId = auth.orgId {
                    LabeledContent("Org ID", value: orgId)
                }
                LabeledContent("Role", value: auth.userRole?.capitalized ?? "Member")
            }

            Section("Platform") {
                LabeledContent("API", value: "kontra-api.onrender.com")
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("iOS Target", value: "iOS 17+")
            }

            Section("Modules") {
                NavigationLink("Portfolio", destination: PortfolioView())
                NavigationLink("Servicing", destination: ServicingView())
                NavigationLink("Governance", destination: GovernanceView())
                NavigationLink("Capital Markets", destination: MarketsView())
                NavigationLink("AI Insights", destination: AIInsightsView())
            }

            Section {
                Button(role: .destructive) {
                    showSignOutConfirm = true
                } label: {
                    Label("Sign Out", systemImage: "arrow.right.square.fill")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .confirmationDialog("Sign out of Kontra?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                auth.signOut()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
