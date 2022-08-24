import SwiftUI
import CodefaceCore
import SwiftLSP
import SwiftyToolz

struct ArtifactView: View
{
    var body: some View
    {
        ZStack
        {
            ArtifactHeaderView(artifactVM: artifactVM)
                .framePosition(artifactVM.headerFrame)
            
            ArtifactContentView(artifactVM: artifactVM,
                                pathBar: pathBar,
                                ignoreSearchFilter: ignoreSearchFilter,
                                bgBrightness: bgBrightness,
                                isShownInScope: isShownInScope)
            .framePosition(artifactVM.contentFrame)
            .opacity(artifactVM.showsContent ? 1.0 : 0)
        }
        .onHover
        {
            guard isShownInScope else { return }
            
            if $0
            {
                isHovering = true
                artifactVM.isInFocus = true
                pathBar.artifactVMStack += artifactVM
            }
            else
            {
                withAnimation(.easeInOut)
                {
                    self.isHovering = false
                    artifactVM.isInFocus = false
                    if !pathBar.artifactVMStack.isEmpty
                    {
                        pathBar.artifactVMStack.removeLast()
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 5)
            .fill(Color(white: bgBrightness).opacity(0.9))
            .overlay(RoundedRectangle(cornerRadius: 5)
                .strokeBorder(isHovering ? Color.accentColor : .primary.opacity(0.25),
                              antialiased: true)))
        .framePosition(artifactVM.frameInScopeContent)
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
    let pathBar: PathBar
    let ignoreSearchFilter: Bool
    @State var isHovering: Bool = false
    let bgBrightness: Double
    let isShownInScope: Bool
}
