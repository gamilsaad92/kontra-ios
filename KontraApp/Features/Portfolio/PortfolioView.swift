import SwiftUI

struct PortfolioView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: LoansView()) {
                        Label("Loans", systemImage: "banknote.fill")
                    }
                    NavigationLink(destination: AssetsView()) {
                        Label("Assets", systemImage: "building.2.fill")
                    }
                }

                Section("About Portfolio") {
                    Text("Manage your multifamily and CRE loan portfolio, track assets, and monitor performance metrics.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Portfolio")
        }
    }
}
