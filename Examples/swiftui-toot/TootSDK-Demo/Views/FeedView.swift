//
//  FeedView.swift
//  TootSDK-Demo
//
//  Created by dave on 6/11/22.
//

import SwiftUI
import TootSDK

struct FeedView: View {
    @EnvironmentObject var tootManager: TootManager
    
    @State var posts: [Status] = []
    @State var name: String = ""
    
    @State var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List(posts, id: \.self) { data in
                Button {
                    self.path.append(data.id)
                } label: {
                    self.row(data)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Feed")
            .navigationDestination(for: String.self) { value in
                PostOperationsView(postID: .constant(value), path: $path)
            }
        }
        .task {
            // Only opt in, if we have data loaded
            guard let currentClient = tootManager.currentClient else { return }
            
            // opt into account updates
            Task {
                for await account in try await currentClient.data.stream(.verifyCredentials) {
                    print("got account update")
                    name = account.displayName ?? "-"
                }
            }
            
            // opt into status updates
            Task {
                for await updatedPosts in try await currentClient.data.stream(.timeLineHome) {
                    print("got a batch of posts")
                    posts = updatedPosts
                }
            }
            
            refresh()
        }
        .refreshable {
            refresh()
        }
    }
    
    @ViewBuilder func row(_ post: Status) -> some View {
        HStack(alignment: .top) {
            AsyncImage(url: URL(string: post.account.avatar)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            
            VStack {
                HStack {
                    Text(post.account.displayName ?? "?")
                        .font(.caption.bold())
                    Text(post.account.username)
                        .font(.caption)
                }
                
                Text(post.content ?? "?")
                    .font(.body)
            }
        }
    }
    
    func refresh() {
        Task {
            try await tootManager.currentClient?.data.refresh(.timeLineHome)
            try await tootManager.currentClient?.data.refresh(.verifyCredentials)
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}