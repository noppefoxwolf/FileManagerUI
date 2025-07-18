import FileManagerUI
import SwiftUI

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showingFileManager = false

    var body: some View {
        VStack(spacing: 20) {
            Text("FileManagerUI Example")
                .font(.largeTitle)
                .fontWeight(.bold)

            Button("Open File Manager") {
                showingFileManager = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .sheet(isPresented: $showingFileManager) {
            FileManagerView()
        }
    }
}
