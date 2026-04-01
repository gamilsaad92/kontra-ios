import SwiftUI

// MARK: - Generic create entity sheet
// Used by all list views to create new records via the standard POST endpoint.

struct CreateEntitySheet: View {
    let title: String
    let path: String
    let onCreated: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var itemTitle = ""
    @State private var isCreating = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $itemTitle)
                        .autocorrectionDisabled()
                }
                if let err = error {
                    Section {
                        Label(err, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.kontraRed)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task { await create() }
                    }
                    .disabled(isCreating)
                }
            }
            .overlay {
                if isCreating {
                    ProgressView("Creating…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
        }
    }

    private func create() async {
        isCreating = true
        defer { isCreating = false }
        error = nil
        do {
            let _: KontraEntity = try await APIClient.shared.createEntity(
                path,
                title: itemTitle.isEmpty ? "New Item" : itemTitle
            )
            onCreated()
            dismiss()
        } catch let e as APIError {
            error = e.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }
}
