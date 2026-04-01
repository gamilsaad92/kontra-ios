import SwiftUI

struct LoansView: View {
    @StateObject private var vm = EntityListViewModel<Loan>(path: "/api/portfolio/loans")
    @State private var showCreate = false
    @State private var selectedLoan: Loan?

    var body: some View {
        List {
            if vm.items.isEmpty && !vm.isLoading {
                ContentUnavailableView("No Loans", systemImage: "banknote", description: Text("Tap + to add your first loan."))
                    .listRowBackground(Color.clear)
            } else {
                ForEach(vm.items) { loan in
                    Button { selectedLoan = loan } label: {
                        LoanRowView(loan: loan)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Loans")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showCreate = true } label: { Image(systemName: "plus") }
            }
        }
        .refreshable { await vm.load() }
        .task { await vm.load() }
        .overlay { if vm.isLoading && vm.items.isEmpty { ProgressView() } }
        .sheet(item: $selectedLoan) { loan in
            LoanDetailView(loan: loan)
        }
        .sheet(isPresented: $showCreate) {
            CreateEntitySheet(title: "New Loan", path: "/api/portfolio/loans") {
                Task { await vm.load() }
            }
        }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}

struct LoanRowView: View {
    let loan: Loan
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(loan.displayName)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Spacer()
                StatusBadgeView(badge: loan.statusBadge)
            }
            HStack(spacing: 12) {
                if let amt = loan.formattedAmount {
                    Label(amt, systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let rate = loan.interestRate {
                    Label(String(format: "%.2f%%", rate), systemImage: "percent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let months = loan.termMonths, months > 0 {
                    Label("\(months)mo", systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
