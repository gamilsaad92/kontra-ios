import SwiftUI

struct PoolsView: View {
    @StateObject private var vm = EntityListViewModel<Pool>(path: "/api/markets/pools")
    @State private var showCreate = false

    var body: some View {
        List {
            if vm.items.isEmpty && !vm.isLoading {
                ContentUnavailableView("No Pools", systemImage: "circle.grid.3x3", description: Text("Tap + to create your first capital pool."))
                    .listRowBackground(Color.clear)
            } else {
                ForEach(vm.items) { pool in
                    NavigationLink(destination: PoolDetailView(pool: pool)) {
                        PoolRowView(pool: pool)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Pools")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showCreate = true } label: { Image(systemName: "plus") }
            }
        }
        .refreshable { await vm.load() }
        .task { await vm.load() }
        .overlay { if vm.isLoading && vm.items.isEmpty { ProgressView() } }
        .sheet(isPresented: $showCreate) {
            CreateEntitySheet(title: "New Pool", path: "/api/markets/pools") {
                Task { await vm.load() }
            }
        }
    }
}

struct PoolRowView: View {
    let pool: Pool
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(pool.displayTitle)
                    .fontWeight(.medium)
                Spacer()
                StatusBadgeView(badge: pool.statusBadge)
            }
            HStack(spacing: 10) {
                if pool.isTokenized, let symbol = pool.tokenSymbol {
                    Label(symbol, systemImage: "bitcoinsign.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.kontraGreen)
                }
                if let supply = pool.tokenSupply {
                    Label(NumberFormatter.currency.string(from: NSNumber(value: supply)) ?? "\(supply)", systemImage: "number.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct PoolDetailView: View {
    let pool: Pool
    @State private var isTokenizing = false
    @State private var tokenizeError: String?

    var body: some View {
        List {
            Section("Pool Info") {
                DetailRow(label: "Title",   value: pool.displayTitle)
                DetailRow(label: "Status",  value: pool.status.capitalized)
                DetailRow(label: "ID",      value: pool.id)
                if let created = pool.createdAt {
                    DetailRow(label: "Created", value: created.prefix(10).description)
                }
            }

            if pool.isTokenized {
                Section("Token") {
                    if let sym = pool.tokenSymbol { DetailRow(label: "Symbol", value: sym) }
                    if let supply = pool.tokenSupply { DetailRow(label: "Supply", value: "\(supply)") }
                    if let net = pool.tokenNetwork { DetailRow(label: "Network", value: net) }
                }
            } else {
                Section("Tokenize") {
                    Button {
                        // Tokenization requires additional inputs — placeholder
                    } label: {
                        Label("Tokenize This Pool", systemImage: "bitcoinsign.circle")
                            .foregroundStyle(.kontraAccent)
                    }
                    Text("Tokenization creates an ERC-20 on Base mainnet. Use the web platform to complete the 4-step flow.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Pool Loans") {
                NavigationLink("View Assigned Loans") {
                    EntityListPage(title: "Pool Loans", path: "/api/markets/pools/\(pool.id)/loans", icon: "banknote.fill")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(pool.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
