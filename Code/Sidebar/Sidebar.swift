import SwiftUI

struct Sidebar: View
{
    var body: some View
    {
        switch viewModel.analysisState
        {
        case .succeeded(let rootArtifact):
            List([rootArtifact],
                 children: \.children,
                 selection: $viewModel.selectedArtifact)
            {
                artifact in
                
                SidebarRow(artifact: artifact, viewModel: viewModel)
            }
            .listStyle(.sidebar)
            .toolbar
            {
                Button(action: toggleSidebar)
                {
                    Image(systemName: "sidebar.leading")
                }
            }
            .onReceive(viewModel.$isSearching)
            {
                if !$0 { dismissSearch() }
            }
            .onChange(of: isSearching)
            {
                [isSearching] isSearchingNow in
                
                if !isSearching, isSearchingNow
                {
                    viewModel.beginSearch()
                }
            }
        case .running:
            ProgressView()
                .progressViewStyle(.circular)
        case .stopped:
            Text("Load a project via the File menu")
                .padding()
        case .failed(let errorMessage):
            Text("An error occured during analysis:\n" + errorMessage)
                .foregroundColor(Color(NSColor.systemRed))
                .padding()
        }
    }
    
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch
    
    @ObservedObject var viewModel: Codeface
}

extension CodeArtifact: Hashable
{
    nonisolated static func == (lhs: CodeArtifact, rhs: CodeArtifact) -> Bool
    {
        // TODO: implement true equality instead of identity
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}

private extension CodeArtifact
{
    var children: [CodeArtifact]?
    {
        parts.isEmpty ? nil : parts
    }
}
