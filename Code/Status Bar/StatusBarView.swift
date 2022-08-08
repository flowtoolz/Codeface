import SwiftUI

struct StatusBarView: View
{
    var body: some View
    {
        HStack(alignment: .firstTextBaseline, spacing: 0)
        {
            ForEach(statusBar.artifactVMStack.indices, id: \.self)
            {
                let vm = statusBar.artifactVMStack[$0]
                
                if $0 > 0
                {
                    Image(systemName: "chevron.compact.right")
                        .foregroundColor(.secondary)
                        .imageScale(.large)
                        .padding([.leading, .trailing], 3)
                }
                ArtifactIcon(artifact: vm, isSelected: false)
                    .padding(.trailing, 3)
                Text(vm.codeArtifact.name)
                    .font(.callout)
            }
            
            Spacer()
        }
        .padding(.leading)
        .frame(height: 29)
        .background(colorScheme == .dark ? Color(white: 0.08) : Color(NSColor.controlBackgroundColor))
    }
    
    @ObservedObject var statusBar: StatusBar
    @Environment(\.colorScheme) private var colorScheme
}
