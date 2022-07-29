extension CodeArtifact
{
    var linesOfCode: Int
    {
        metrics.linesOfCode ?? 0
    }
    
    func contains(_ otherArtifact: CodeArtifact) -> Bool
    {
        if otherArtifact === self { return true }
        guard let otherArtifactScope = otherArtifact.scope else { return false }
        return self === otherArtifactScope ? true : contains(otherArtifactScope)
    }
}

protocol CodeArtifact: AnyObject
{
    var metrics: Metrics { get }
    
    var scope: CodeArtifact? { get }
    
    var name: String { get }
    var kindName: String { get }
    var code: String? { get }
    
    var id: String { get }
}
