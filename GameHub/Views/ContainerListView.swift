//
//  ContainerListView.swift
//  GameHub
//

import SwiftUI
import UniformTypeIdentifiers

struct ContainerListView: View {
    @EnvironmentObject var containerManager: ContainerManager
    @State private var showingImporter = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(containerManager.containers) { container in
                        ContainerRowView(container: container)
                    }
                    .onDelete(perform: containerManager.removeContainers)
                } header: {
                    Text("BoxedWine / Game Containers")
                } footer: {
                    Text("Import a boxedwine.zip (or compatible container). Each container can hold Wine + your .exe. For best speed, enable JIT via StikJIT (Settings).")
                }

                Section {
                    Button {
                        showingImporter = true
                    } label: {
                        Label("Import Container (boxedwine.zip)", systemImage: "square.and.arrow.down")
                    }
                    .disabled(!containerManager.canImport)
                }
            }
            .navigationTitle("Containers")
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.zip],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    _ = url.startAccessingSecurityScopedResource()
                    containerManager.importContainer(from: url) { msg in
                        alertMessage = msg
                        showingAlert = true
                    }
                case .failure(let error):
                    alertMessage = "Import failed: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
            .alert("Container", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct ContainerRowView: View {
    @EnvironmentObject var containerManager: ContainerManager
    let container: GameContainer
    @State private var showAddGame = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "archivebox.fill")
                    .foregroundStyle(.secondary)
                Text(container.name)
                    .font(.headline)
                Spacer()
                Button("Add game") {
                    showAddGame = true
                }
                .font(.caption)
            }
            Text(container.path)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showAddGame) {
            AddGameView(container: container) {
                showAddGame = false
            }
            .environmentObject(containerManager)
        }
    }
}

struct AddGameView: View {
    @EnvironmentObject var containerManager: ContainerManager
    let container: GameContainer
    let onDismiss: () -> Void
    @State private var name = ""
    @State private var exePath = "imgtool.exe"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Game name", text: $name, prompt: Text("e.g. imgtool"))
                TextField("Exe path", text: $exePath, prompt: Text("e.g. imgtool.exe"))
                    .textInputAutocapitalization(.never)
            }
            .navigationTitle("Add game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let n = name.isEmpty ? (exePath as NSString).deletingPathExtension : name
                        containerManager.addGame(name: n, exePath: exePath, containerId: container.path, containerName: container.name)
                        onDismiss()
                    }
                    .disabled(exePath.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContainerListView()
            .environmentObject(ContainerManager.shared)
    }
}
