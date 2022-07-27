import Foundation

@MainActor
class CodeFileArtifact: Identifiable, ObservableObject
{
    init(codeFile: CodeFile, scope: CodeFolderArtifact?)
    {
        self.codeFile = codeFile
        self.scope = scope
    }
    
    // Mark: - Metrics
    
    var metrics = Metrics()
    
    // Mark: - Search
    
    @Published var passesSearchFilter = true
    
    var containsSearchTermRegardlessOfParts: Bool?
    var partsContainSearchTerm: Bool?
    
    // Mark: - Tree Structure
    
    weak var scope: CodeFolderArtifact?
    
    var symbols = [CodeSymbolArtifact]()
    
    // Mark: - Basics
    
    var name: String { codeFile.name }
    var kindName: String { "File" }
    var code: String? { codeFile.code }

    let id = UUID().uuidString
    let codeFile: CodeFile
}
