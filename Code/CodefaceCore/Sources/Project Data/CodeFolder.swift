public class CodeFolder: Codable, Equatable
{
    public static func == (lhs: CodeFolder, rhs: CodeFolder) -> Bool
    {
        lhs === rhs
    }
    
    var looksLikeAPackage: Bool
    {
        if name.lowercased().contains("package") { return true }
        
        return files?.contains { $0.name.lowercased().contains("package") } ?? false
    }
    
    init(name: String, files: [CodeFile], subfolders: [CodeFolder])
    {
        self.name = name
        self.files = files.isEmpty ? nil : files
        self.subfolders = subfolders.isEmpty ? nil : subfolders
    }
    
    let name: String
    let files: [CodeFile]?
    let subfolders: [CodeFolder]?
}
