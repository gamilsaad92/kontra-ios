import SwiftUI

// MARK: - Generic Entity List ViewModel

@MainActor
class EntityListViewModel<T: Decodable & Identifiable>: ObservableObject {
    @Published var items: [T] = []
    @Published var total = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    let path: String

    init(path: String) {
        self.path = path
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            let list: EntityList<T> = try await APIClient.shared.listEntities(path)
            items = list.items
            total = list.total
        } catch let e as APIError {
            errorMessage = e.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createItem(title: String) async throws {
        let _: KontraEntity = try await APIClient.shared.createEntity(path, title: title)
        await load()
    }
}

// MARK: - EntityRowView (generic row for KontraEntity)

struct EntityRowView: View {
    let entity: KontraEntity
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entity.displayTitle)
                    .fontWeight(.medium)
                Spacer()
                StatusBadgeView(badge: entity.statusBadge)
            }
            if let date = entity.formattedDate {
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Generic entity detail

struct EntityDetailView: View {
    let entity: KontraEntity
    let module: String
    let resource: String

    var body: some View {
        List {
            Section("Details") {
                DetailRow(label: "Title",   value: entity.displayTitle)
                DetailRow(label: "Status",  value: entity.status.capitalized)
                DetailRow(label: "ID",      value: entity.id)
                if let created = entity.formattedDate {
                    DetailRow(label: "Created", value: created)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(entity.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - EntityListPage (reusable for any module/resource)
// Used by Servicing, Governance, Markets, and other modules

struct EntityListPage: View {
    let title: String
    let path: String
    let icon: String
    @StateObject private var vm: EntityListViewModel<KontraEntity>
    @State private var showCreate = false

    init(title: String, path: String, icon: String) {
        self.title = title
        self.path  = path
        self.icon  = icon
        _vm = StateObject(wrappedValue: EntityListViewModel<KontraEntity>(path: path))
    }

    var body: some View {
        List {
            if vm.items.isEmpty && !vm.isLoading {
                ContentUnavailableView(
                    "No \(title)",
                    systemImage: icon,
                    description: Text("Tap + to add your first record.")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(vm.items) { item in
                    NavigationLink(destination: EntityDetailView(entity: item, module: "", resource: "")) {
                        EntityRowView(entity: item)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showCreate = true } label: { Image(systemName: "plus") }
            }
        }
        .refreshable { await vm.load() }
        .task { await vm.load() }
        .overlay {
            if vm.isLoading && vm.items.isEmpty { ProgressView() }
        }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .sheet(isPresented: $showCreate) {
            CreateEntitySheet(title: "New \(title.dropLast(title.hasSuffix("s") ? 1 : 0))", path: path) {
                Task { await vm.load() }
            }
        }
    }
}
