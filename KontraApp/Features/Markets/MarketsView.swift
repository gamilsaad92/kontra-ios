import SwiftUI

struct MarketsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Capital Markets") {
                    NavigationLink(destination: PoolsView()) {
                        Label("Pools", systemImage: "circle.grid.3x3.fill")
                    }
                    NavigationLink(destination: EntityListPage(title: "Tokens", path: "/api/markets/tokens", icon: "bitcoinsign.circle.fill")) {
                        Label("Tokens", systemImage: "bitcoinsign.circle.fill")
                    }
                    NavigationLink(destination: EntityListPage(title: "Exchange Listings", path: "/api/markets/exchange-listings", icon: "list.bullet.rectangle.fill")) {
                        Label("Exchange Listings", systemImage: "list.bullet.rectangle.fill")
                    }
                }

                Section("Reports") {
                    NavigationLink(destination: EntityListPage(title: "Reports", path: "/api/reports/reports", icon: "doc.plaintext.fill")) {
                        Label("Reports", systemImage: "doc.plaintext.fill")
                    }
                }

                Section("Settings") {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Markets")
        }
    }
}
