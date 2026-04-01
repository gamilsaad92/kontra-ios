import SwiftUI

struct AssetsView: View {
    @StateObject private var vm = EntityListViewModel<KontraEntity>(path: "/api/portfolio/assets")
    @State private var showCreate = false

    var body: some View {
        List {
            if vm.items.isEmpty && !vm.isLoading {
                ContentUnavailableView("No Assets", systemImage: "building.2", description: Text("Tap + to add your first asset."))
                    .listRowBackground(Color.clear)
            } else {
                ForEach(vm.items) { asset in
                    NavigationLink(destination: EntityDetailView(entity: asset, module: "portfolio", resource: "assets")) {
                        EntityRowView(entity: asset)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Assets")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showCreate = true } label: { Image(systemName: "plus") }
            }
        }
        .refreshable { await vm.load() }
        .task { await vm.load() }
        .overlay { if vm.isLoading && vm.items.isEmpty { ProgressView() } }
        .sheet(isPresented: $showCreate) {
            CreateEntitySheet(title: "New Asset", path: "/api/portfolio/assets") {
                Task { await vm.load() }
            }
        }
    }
}
