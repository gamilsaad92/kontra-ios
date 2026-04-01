import SwiftUI

struct LoanDetailView: View {
    let loan: Loan
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Loan Information") {
                    DetailRow(label: "Borrower", value: loan.borrowerName ?? "—")
                    DetailRow(label: "Status", value: loan.status.capitalized)
                    if let amt = loan.formattedAmount {
                        DetailRow(label: "Amount", value: amt)
                    }
                    if let rate = loan.interestRate {
                        DetailRow(label: "Interest Rate", value: String(format: "%.3f%%", rate))
                    }
                    if let months = loan.termMonths {
                        DetailRow(label: "Term", value: "\(months) months")
                    }
                    if let start = loan.startDate {
                        DetailRow(label: "Start Date", value: start)
                    }
                }

                Section("System") {
                    DetailRow(label: "ID", value: loan.id)
                    if let created = loan.createdAt {
                        DetailRow(label: "Created", value: created.prefix(10).description)
                    }
                }

                Section("Servicing") {
                    NavigationLink("View Payments") {
                        EntityListPage(title: "Payments", path: "/api/servicing/payments", icon: "dollarsign.circle.fill")
                    }
                    NavigationLink("View Inspections") {
                        EntityListPage(title: "Inspections", path: "/api/servicing/inspections", icon: "magnifyingglass.circle.fill")
                    }
                    NavigationLink("View Draws") {
                        EntityListPage(title: "Draws", path: "/api/servicing/draws", icon: "arrow.down.circle.fill")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(loan.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
            Spacer()
        }
    }
}
