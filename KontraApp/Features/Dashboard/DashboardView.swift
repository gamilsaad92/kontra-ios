import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var auth: AuthManager
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        NavigationStack {
            List {
                // Summary stats
                Section {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Total Loans",   value: "\(vm.stats.totalLoans)",   subtitle: "in portfolio")
                        StatCard(title: "Total Assets",  value: "\(vm.stats.totalAssets)",  subtitle: "tracked")
                        StatCard(title: "Active Pools",  value: "\(vm.stats.activePools)",  subtitle: "on-chain ready", accentColor: .kontraGreen)
                        StatCard(title: "AI Reviews",    value: "\(vm.stats.aiReviews)",    subtitle: "pending", accentColor: .kontraYellow)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                // Recent loans
                if !vm.recentLoans.isEmpty {
                    Section("Recent Loans") {
                        ForEach(vm.recentLoans) { loan in
                            LoanRowView(loan: loan)
                        }
                    }
                }

                // Recent pools
                if !vm.recentPools.isEmpty {
                    Section("Recent Pools") {
                        ForEach(vm.recentPools) { pool in
                            PoolRowView(pool: pool)
                        }
                    }
                }

                // AI alerts
                if !vm.aiAlerts.isEmpty {
                    Section("AI Flags") {
                        ForEach(vm.aiAlerts) { review in
                            AIReviewRowView(review: review)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(auth.userEmail ?? "Kontra")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .refreshable { await vm.loadAll() }
            .overlay {
                if vm.isLoading { ProgressView("Loading…").frame(maxWidth: .infinity, maxHeight: .infinity).background(.ultraThinMaterial) }
            }
            .task { await vm.loadAll() }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var stats = DashboardStats()
    @Published var recentLoans: [Loan] = []
    @Published var recentPools: [Pool] = []
    @Published var aiAlerts: [AIReview] = []
    @Published var isLoading = false

    func loadAll() async {
        isLoading = true
        defer { isLoading = false }
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchLoans() }
            group.addTask { await self.fetchPools() }
            group.addTask { await self.fetchAIReviews() }
            group.addTask { await self.fetchAssets() }
        }
    }

    private func fetchLoans() async {
        guard let list = try? await APIClient.shared.listEntities("/api/portfolio/loans") as EntityList<Loan> else { return }
        recentLoans = Array(list.items.prefix(5))
        stats.totalLoans = list.total
    }

    private func fetchAssets() async {
        guard let list = try? await APIClient.shared.listEntities("/api/portfolio/assets") as EntityList<KontraEntity> else { return }
        stats.totalAssets = list.total
    }

    private func fetchPools() async {
        guard let list = try? await APIClient.shared.listEntities("/api/markets/pools") as EntityList<Pool> else { return }
        recentPools = Array(list.items.prefix(5))
        stats.activePools = list.items.filter { $0.status == "active" }.count
    }

    private func fetchAIReviews() async {
        guard let list = try? await APIClient.shared.listEntities("/api/ai/reviews") as EntityList<AIReview> else { return }
        aiAlerts = list.items.filter { $0.status == "pending" }.prefix(3).map { $0 }
        stats.aiReviews = list.items.filter { $0.status == "pending" }.count
    }
}

struct DashboardStats {
    var totalLoans = 0
    var totalAssets = 0
    var activePools = 0
    var aiReviews = 0
}
