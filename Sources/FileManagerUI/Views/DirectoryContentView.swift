import SwiftUI

struct DirectoryContentView: View {
    @State private var store: DirectoryStore
    @State private var showingCreateDirectoryAlert = false
    @State private var showingCreateFileAlert = false
    @State private var newItemName = ""
    @State private var selectedItems: Set<FileItem.ID> = []
    @State private var showingRenameAlert = false
    @State private var itemToRename: FileItem?
    @State private var renameText = ""
    @State private var quickLookItem: URL?
    @State private var viewMode: ViewMode = .list
    @State private var editMode: EditMode = .inactive

    init(path: URL? = nil, fileManager: FileManager = .default) {
        self._store = State(wrappedValue: DirectoryStore(path: path, fileManager: fileManager))
    }

    private func renameItem(_ item: FileItem) {
        itemToRename = item
        renameText = item.name
        showingRenameAlert = true
    }

    private func previewFile(_ url: URL) {
        quickLookItem = url
    }

    var body: some View {
        mainContentView
            .navigationTitle(
                store.currentPath.lastPathComponent.isEmpty
                    ? "/" : store.currentPath.lastPathComponent
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert("New Folder", isPresented: $showingCreateDirectoryAlert) {
                createDirectoryAlert
            }
            .alert("New File", isPresented: $showingCreateFileAlert) {
                createFileAlert
            }
            .alert("Rename", isPresented: $showingRenameAlert) {
                renameAlert
            }
            .quickLookPreview($quickLookItem)
            .onChange(of: editMode) { _, newValue in
                if newValue != .active {
                    selectedItems.removeAll()
                }
            }
            .environment(\.editMode, $editMode)
    }

    @ViewBuilder
    private var mainContentView: some View {
        Group {
            if let error = store.error {
                errorStateView(error: error)
            } else if store.items.isEmpty && !store.isLoading {
                emptyStateView
            } else {
                fileListView
            }
        }
    }

    private func errorStateView(error: Error) -> some View {
        let nsError = error as NSError
        let isPermissionError =
            nsError.code == NSFileReadNoPermissionError || nsError.code == NSFileReadNoSuchFileError
            || nsError.domain == NSCocoaErrorDomain

        return ContentUnavailableView(
            isPermissionError ? "Access Denied" : "Error",
            systemImage: isPermissionError ? "lock.fill" : "exclamationmark.triangle.fill",
            description: Text(
                isPermissionError
                    ? "You don't have permission to access this folder" : error.localizedDescription
            )
        )
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "Folder is empty",
            systemImage: "folder",
            description: Text("This folder contains no files or folders")
        )
    }

    private var fileListView: some View {
        ZStack {
            Group {
                if viewMode == .list {
                    List(selection: $selectedItems) {
                        ForEach(store.items) { item in
                            if item.isDirectory {
                                directoryRowView(item: item)
                            } else {
                                fileRowView(item: item)
                            }
                        }
                        .deleteDisabled(true)
                    }
                    .listStyle(PlainListStyle())
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.adaptive(minimum: 60), spacing: 16)
                            ],
                            spacing: 16
                        ) {
                            ForEach(store.items) { item in
                                if item.isDirectory {
                                    directoryGridView(item: item)
                                } else {
                                    fileGridView(item: item)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            if store.isLoading && store.items.isEmpty {
                ProgressView()
            }
        }
    }

    private func directoryRowView(item: FileItem) -> some View {
        NavigationLink(value: item.url) {
            FileItemRow(item: item)
        }
        .contextMenu {
            directoryContextMenu(item: item)
        }
    }

    private func fileRowView(item: FileItem) -> some View {
        FileItemRow(item: item)
            .contentShape(Rectangle())
            .onTapGesture {
                if editMode == .active {
                    if selectedItems.contains(item.id) {
                        selectedItems.remove(item.id)
                    } else {
                        selectedItems.insert(item.id)
                    }
                } else {
                    previewFile(item.url)
                }
            }
            .contextMenu {
                fileContextMenu(item: item)
            }
    }

    private func directoryGridView(item: FileItem) -> some View {
        let isSelected = selectedItems.contains(item.id)
        let isEditMode = editMode == .active

        return Group {
            if isEditMode {
                Button(action: {
                    if isSelected {
                        selectedItems.remove(item.id)
                    } else {
                        selectedItems.insert(item.id)
                    }
                }) {
                    FileItemGridCell(item: item, isSelected: isSelected, isEditMode: isEditMode)
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink(value: item.url) {
                    FileItemGridCell(item: item, isSelected: isSelected, isEditMode: isEditMode)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        }
        .contextMenu {
            directoryContextMenu(item: item)
        }
    }

    private func fileGridView(item: FileItem) -> some View {
        let isSelected = selectedItems.contains(item.id)
        let isEditMode = editMode == .active

        return Button(action: {
            if isEditMode {
                if isSelected {
                    selectedItems.remove(item.id)
                } else {
                    selectedItems.insert(item.id)
                }
            } else {
                previewFile(item.url)
            }
        }) {
            FileItemGridCell(item: item, isSelected: isSelected, isEditMode: isEditMode)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .contextMenu {
            fileContextMenu(item: item)
        }
    }

    @ViewBuilder
    private func directoryContextMenu(item: FileItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)

            Text("Type: Folder")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Modified: \(item.formattedDate)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)

        Divider()

        Button(action: {
            renameItem(item)
        }) {
            Label("Rename", systemImage: "pencil")
        }
    }

    @ViewBuilder
    private func fileContextMenu(item: FileItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)

            Text("Type: \(item.typeDescription)")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Extension: \(item.fileExtension)")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("MIME Type: \(item.mimeType)")
                .font(.caption)
                .foregroundColor(.secondary)

            if let size = item.size {
                Text("Size: \(item.formattedSize)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text("Modified: \(item.formattedDate)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)

        Divider()

        Button(action: {
            previewFile(item.url)
        }) {
            Label("Preview", systemImage: "eye")
        }

        Button(action: {
            renameItem(item)
        }) {
            Label("Rename", systemImage: "pencil")
        }

        ShareLink(item: item.url) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarTitleMenu {
            directoryInfoView
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if editMode == .active {
                Button("Done") {
                    editMode = .inactive
                }
            } else {
                Menu {
                    Button(action: {
                        viewMode = viewMode == .list ? .grid : .list
                    }) {
                        Label(
                            viewMode == .list ? "Grid View" : "List View",
                            systemImage: viewMode == .list ? "square.grid.2x2" : "list.bullet"
                        )
                    }

                    Toggle(isOn: $store.showHiddenFiles) {
                        Label(
                            store.showHiddenFiles ? "Hide Hidden Files" : "Show Hidden Files",
                            systemImage: store.showHiddenFiles ? "eye.slash" : "eye"
                        )
                    }

                    Divider()

                    Button(action: {
                        NotificationCenter.default.post(name: .jumpToAppContainer, object: nil)
                    }) {
                        Label("Go to App Container", systemImage: "house")
                    }

                    Button(action: { store.refresh() }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }

                    Divider()

                    Button(action: { showingCreateDirectoryAlert = true }) {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }

                    Button(action: { showingCreateFileAlert = true }) {
                        Label("New File", systemImage: "doc.badge.plus")
                    }

                    Divider()

                    Button(action: {
                        editMode = .active
                    }) {
                        Label("Select", systemImage: "checkmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }

        ToolbarItemGroup(placement: .bottomBar) {
            if editMode == .active {
                editModeBottomBar
            }
        }
    }

    @ViewBuilder
    private var editModeBottomBar: some View {
        ShareLink(items: selectedItemURLs) {
            Image(systemName: "square.and.arrow.up")
        }
        .disabled(selectedItems.isEmpty)

        Spacer()

        Text("\(selectedItems.count) selected")
            .font(.caption)
            .foregroundColor(.secondary)

        Spacer()

        Button(
            role: .destructive,
            action: {
                store.deleteItems(withIDs: selectedItems)
                selectedItems.removeAll()
            }
        ) {
            Image(systemName: "trash")
        }
        .disabled(selectedItems.isEmpty)
    }

    private var selectedItemURLs: [URL] {
        selectedItems.compactMap { id in
            store.items.first(where: { $0.id == id })?.url
        }
    }

    @ViewBuilder
    private var directoryInfoView: some View {
        if let info = store.directoryInfo {
            VStack(alignment: .leading, spacing: 4) {
                Button(action: {
                    UIPasteboard.general.string = info.path
                }) {
                    HStack {
                        Text("Path: \(info.path)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)

                HStack {
                    Text("Folders: \(info.directoryCount)")
                        .font(.caption)
                    Text("Files: \(info.fileCount)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)

                Text("Total Size: \(info.formattedTotalSize)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Divider()

                Text("Created: \(info.formattedCreationDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Modified: \(info.formattedModificationDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var createDirectoryAlert: some View {
        TextField("Folder name", text: $newItemName)
        Button("Create") {
            if !newItemName.isEmpty {
                do {
                    try store.createDirectory(name: newItemName)
                    newItemName = ""
                } catch {
                    // Error handling
                }
            }
        }
        Button("Cancel", role: .cancel) {
            newItemName = ""
        }
    }

    @ViewBuilder
    private var createFileAlert: some View {
        TextField("File name", text: $newItemName)
        Button("Create") {
            if !newItemName.isEmpty {
                do {
                    try store.createFile(name: newItemName)
                    newItemName = ""
                } catch {
                    // Error handling
                }
            }
        }
        Button("Cancel", role: .cancel) {
            newItemName = ""
        }
    }

    @ViewBuilder
    private var renameAlert: some View {
        TextField("New name", text: $renameText)
        Button("Rename") {
            if !renameText.isEmpty, let item = itemToRename {
                do {
                    try store.renameItem(at: item.url, newName: renameText)
                    itemToRename = nil
                    renameText = ""
                } catch {
                    // Error handling
                }
            }
        }
        Button("Cancel", role: .cancel) {
            itemToRename = nil
            renameText = ""
        }
    }
}
