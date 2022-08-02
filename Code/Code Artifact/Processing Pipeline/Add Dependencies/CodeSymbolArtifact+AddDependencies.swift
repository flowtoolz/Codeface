import SwiftLSP
import SwiftyToolz

extension CodeSymbolArtifact
{
    func addDependencies(enclosingFile file: LSPDocumentUri,
                         hashMap: CodeFileArtifactHashmap,
                         server: LSP.ServerCommunicationHandler) async throws
    {
        for subsymbol in subSymbols
        {
            try await subsymbol.addDependencies(enclosingFile: file,
                                                hashMap: hashMap,
                                                server: server)
        }
        
        guard kind != .Namespace else
        {
            // at least with sourcekit-lsp, this detects many wrong dependencies onto namespaces which are Swift extensions
            return
        }
        
        let refs = try await server.requestReferences(forSymbolSelectionRange: selectionRange,
                                                      in: file)
        
//        print("found \(refs.count) referencing lsp locations for symbol artifact")
        
        for referencingLocation in refs
        {
            guard let referencingFileArtifact = hashMap[referencingLocation.uri] else
            {
                // TODO: contact sourcekit-lsp team about this, maybe open an issue on github ...
                // sourcekit-lsp suggests weird references from Swift SDKs into our code when our code extends basic types like String. we must ignore those references.
                // log(warning: "Could not find file artifact for LSP document URI:\n\(referencingLocation.uri)\nReferenced Symbol \(self.name) of type \(self.kindName) on line \(self.positionInFile) in \(file)")
                continue
            }
            
            guard let referencingSymbolArtifact = referencingFileArtifact.findSymbolArtifact(containing: referencingLocation.range) else
            {
                // TODO: contact sourcekit-lsp team about this, maybe open an issue on github ...
                // sourcekit-lsp suggests a few wrong references where there is one of those issues: a) extension of Variable -> Var namespace declaration (plain wrong) b) class Variable -> namespace Var (wrong direction) or c) all range properties are -1 (invalid)
                // log(warning: "Could not find referencing symbol artifact\nin file:\(referencingLocation.uri)\nat range: \(referencingLocation.range)\nreferenced symbol \(self.name) of type \(self.kindName) on line \(self.positionInFile) in \(file)")
                continue
            }
            
            guard !referencingSymbolArtifact.contains(self) else
            {
                // dependencies of containing symbols onto this one are already implicitly given by that containment (nesting) ... in this context, a symbol also contains itself
                continue
            }
            
            // TODO: further weirdness (?) of sourcekit-lsp: ist suggests that any usage of a type amounts to a reference to every extension of that type, which is simply not true ... it even suggests that different extensions of the same type are references of each other ... seems like it does not really find references of that specific symbol but just all references of the symbol's name (just string matching, no semantics) 🤦🏼‍♂️
            
//            if referencingLocation.uri != file
//            {
//                print("found dependency 🎉\nfrom \(referencingSymbolArtifact.name) of type \(referencingSymbolArtifact.kindName) on line \(referencingLocation.range.start.line) in \(referencingLocation.uri)\nonto \(name) of type \(kindName) on line \(positionInFile) in \(file)\n")
//            }
            
            if scope === referencingSymbolArtifact.scope
            {
                // dependency within same scope (between siblings)
                incomingDependenciesScope += referencingSymbolArtifact
                referencingSymbolArtifact.outgoingDependenciesScope += self
            }
            else
            {
                // across different scopes
                incomingDependenciesExternal += referencingSymbolArtifact
                referencingSymbolArtifact.outgoingDependenciesExternal += self
            }
        }
        
//        print("did add \(incomingDependencies.count) incoming dependencies to symbol artifact")
    }
}

private extension CodeFileArtifact
{
    func findSymbolArtifact(containing range: LSPRange) -> CodeSymbolArtifact?
    {
        for symbol in symbols
        {
            if let artifact = symbol.findSymbolArtifact(containing: range)
            {
                return artifact
            }
        }
        
        return nil
    }
}

private extension CodeSymbolArtifact
{
    func findSymbolArtifact(containing range: LSPRange) -> CodeSymbolArtifact?
    {
        // depth first!!! we want the deepest symbol that contains the range
        for subsymbol in subSymbols
        {
            if let artifact = subsymbol.findSymbolArtifact(containing: range)
            {
                return artifact
            }
        }
        
        return self.range.contains(range) ? self : nil
    }
}
