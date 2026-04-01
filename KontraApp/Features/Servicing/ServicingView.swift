import SwiftUI

struct ServicingView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Loan Servicing") {
                    NavigationLink(destination: EntityListPage(title: "Payments", path: "/api/servicing/payments", icon: "dollarsign.circle.fill")) {
                        Label("Payments", systemImage: "dollarsign.circle.fill")
                    }
                    NavigationLink(destination: EntityListPage(title: "Inspections", path: "/api/servicing/inspections", icon: "magnifyingglass.circle.fill")) {
                        Label("Inspections", systemImage: "magnifyingglass.circle.fill")
                    }
                    NavigationLink(destination: EntityListPage(title: "Draws", path: "/api/servicing/draws", icon: "arrow.down.circle.fill")) {
                        Label("Draws", systemImage: "arrow.down.circle.fill")
                    }
                    NavigationLink(destination: EntityListPage(title: "Escrows", path: "/api/servicing/escrows", icon: "lock.fill")) {
                        Label("Escrows", systemImage: "lock.fill")
                    }
                }

                Section("Borrower Management") {
                    NavigationLink(destination: EntityListPage(title: "Borrower Financials", path: "/api/servicing/borrower-financials", icon: "chart.bar.doc.horizontal.fill")) {
                        Label("Borrower Financials", systemImage: "chart.bar.doc.horizontal.fill")
                    }
                    NavigationLink(destination: EntityListPage(title: "Management", path: "/api/servicing/management", icon: "person.3.fill")) {
                        Label("Management Items", systemImage: "person.3.fill")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Servicing")
        }
    }
}
