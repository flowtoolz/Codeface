public extension CodeFolderArtifact
{
    convenience init(codeFolder: CodeFolder,
                     scope: (any CodeArtifact)?,
                     symbolDataHash: inout [CodeSymbolArtifact: CodeSymbol])
    {
        self.init(name: codeFolder.name, scope: scope)
        
        let partArray = (codeFolder.subfolders ?? []).map
        {
            Part(kind: .subfolder(CodeFolderArtifact(codeFolder: $0,
                                                     scope: self,
                                                     symbolDataHash: &symbolDataHash)))
        }
        +
        (codeFolder.files ?? []).map
        {
            Part(kind: .file(CodeFileArtifact(codeFile: $0,
                                              scope: self,
                                              symbolDataHash: &symbolDataHash)))
        }
        
        for part in partArray
        {
            partGraph.insert(part)
        }
    }
}
