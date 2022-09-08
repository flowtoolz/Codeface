import Foundation
import SwiftNodes
import SwiftyToolz

extension CodeFileArtifact: CodeArtifact
{
    public func sort()
    {
        symbolGraph.sort(by: <)
    }
    
    public var parts: [CodeArtifact]
    {
        symbolGraph.nodesByValueID.values.map { $0.value }
    }
    
    public func addDependency(from source: CodeArtifact,
                              to target: CodeArtifact)
    {
        symbolGraph.addEdge(from: source.id, to: target.id)
    }
    
    public var intrinsicSizeInLinesOfCode: Int? { codeFile.lines.count }
    
    public var name: String { codeFile.name }
    public var kindName: String { "File" }
    public var code: String? { codeFile.code }
}

public class CodeFileArtifact: Identifiable, ObservableObject
{
    public init(codeFile: CodeFile, scope: CodeArtifact)
    {
        self.codeFile = codeFile
        self.scope = scope
        
        for symbolData in codeFile.symbols
        {
            symbolGraph.insert(.init(symbolData: symbolData,
                                     scope: self,
                                     enclosingFile: codeFile))
        }
    }
    
    // MARK: - Metrics
    
    public var metrics = Metrics()
    
    // MARK: - Tree Structure
    
    public weak var scope: CodeArtifact?
    
    public var symbolGraph = Graph<CodeSymbolArtifact>()
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let codeFile: CodeFile
}
