import SwiftUI

struct GovernanceView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Compliance & Risk") {
                    NavigationLink(destination: EntityListPage(title: "Compliance", path: "/api/governance/compliance-items", icon: "checkmark.shield.fill")) {
                        Label("Compliance", systemImage: "checkmark.shield.fill")
                    }
                    NavigationLink(destination: EntityListPage(title: "Risk", path: "/api/governance/risk-items", icon: "exclamationmark.triangle.fill")) {
                        Label("Risk Items", systemImage: "exclamationmark.triangle.fill")
                    }
                    NavigationLink(destination: EntityListPage(title: "Regulatory Scans", path: "/api/governance/regulatory-scans", icon: "doc.text.magnifyingglass")) {
                        Label("Regulatory Scans", systemImage: "doc.text.magnifyingglass")
                    }
                }

                Section("Legal & Documents") {
                    NavigationLink(destination: EntityListPage(title: "Legal Items", path: "/api/governance/legal-items", icon: "doc.badge.gearshape.fill")) {
                        Label("Legal Items", systemImage: "doc.badge.gearshape.fill")
                    }
                    NavigationLink(destination: EntityListPage(title: "Document Reviews", path: "/api/governance/document-reviews", icon: "doc.text.fill")) {
                        Label("Document Reviews", systemImage: "doc.text.fill")
                    }
                }

                Section("AI Insights") {
                    NavigationLink(destination: AIInsightsView()) {
                        Label("AI Reviews", systemImage: "brain.head.profile")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Governance")
        }
    }
}
