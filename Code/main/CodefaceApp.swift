import SwiftUI
import SwiftyToolz

@main
struct CodefaceApp: App {
    
    // TODO: after launch: try Project.loadLastOpenFolder()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            CommandGroup(replacing: .newItem) {
                Button("Load Code Folder...") {
                    isPresented = true
                }
                .keyboardShortcut("l")
                .fileImporter(isPresented: $isPresented,
                              allowedContentTypes: [.directory],
                              allowsMultipleSelection: false,
                              onCompletion: { result in
                    isPresented = false
                    switch result {
                        
                    case .success(let urls):
                        urls.first.forSome {
                            do {
                                try Project.load(newFolder: $0)
                            }
                            catch {
                                log(error)
                            }
                        }
                    case .failure(let error):
                        log(error)
                    }
                    
                })
                
                Button("Reload") {
                    do { try Project.loadLastOpenFolder() }
                    catch { log(error) }
                }
                .keyboardShortcut("r")
            }
        }
    }
    
    @State var isPresented = false
}
