import SwiftUI

struct AIInsightsView: View {
    @StateObject private var vm = AIInsightsViewModel()
    @State private var filter: String = "all"

    private let filters = ["all", "pending", "approved", "rejected"]

    var body: some View {
        List {
            // Filter picker
            Section {
                Picker("Status", selection: $filter) {
                    ForEach(filters, id: \.self) { f in
                        Text(f.capitalized).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            // Reviews list
            let filtered = vm.reviews.filter { filter == "all" || $0.status == filter }
            if filtered.isEmpty && !vm.isLoading {
                ContentUnavailableView(
                    "No AI Reviews",
                    systemImage: "brain.head.profile",
                    description: Text(filter == "all" ? "No AI reviews found for this organization." : "No \(filter) reviews.")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(filtered) { review in
                    AIReviewRowView(review: review)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("AI Insights")
        .refreshable { await vm.load() }
        .task { await vm.load() }
        .overlay { if vm.isLoading && vm.reviews.isEmpty { ProgressView("Loading AI reviews…") } }
    }
}

@MainActor
final class AIInsightsViewModel: ObservableObject {
    @Published var reviews: [AIReview] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let list: EntityList<AIReview> = try await APIClient.shared.listEntities("/api/ai/reviews")
            reviews = list.items
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct AIReviewRowView: View {
    let review: AIReview
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.type?.replacingOccurrences(of: "_", with: " ").capitalized ?? "Review")
                    .fontWeight(.medium)
                Spacer()
                StatusBadgeView(badge: StatusBadge(review.status))
            }
            if let summary = review.summary {
                Text(summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            if let risk = review.riskLevel {
                Label(risk.capitalized, systemImage: "exclamationmark.triangle")
                    .font(.caption2)
                    .foregroundStyle(risk == "high" ? .kontraRed : risk == "medium" ? .kontraYellow : .kontraGreen)
            }
        }
        .padding(.vertical, 4)
    }
}
