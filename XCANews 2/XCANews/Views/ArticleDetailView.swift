//
//  ArticleDetailView.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//


import SwiftUI
import AVKit

struct ArticleDetailView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var socialViewModel: SocialViewModel
    @Environment(\.dismiss) var dismiss
    
    let articleId: String

    var article: UserArticle {
        socialViewModel.userArticles.first(where: { $0.id == articleId })!
    }
    
    @State private var commentText: String = ""
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Author info
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading) {
                        Text(article.authorName)
                            .font(.headline)
                        Text(article.timeAgo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .imageScale(.large)
                    }
                }
                .padding()

                // Image
                if let imageURL = article.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 250)
                        default:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 250)
                                .overlay(ProgressView())
                        }
                    }
                    .frame(maxHeight: 300)
                    .clipped()
                }
                
                // Video
                if let videoURL = article.videoURL, let url = URL(string: videoURL) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 250)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                // Title + Content
                VStack(alignment: .leading, spacing: 12) {
                    Text(article.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(article.content)
                }
                .padding(.horizontal)

                // Likes + Comments
                HStack(spacing: 20) {
                    Button(action: toggleLike) {
                        HStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .primary)
                            Text("\(article.likes.count) likes")
                        }
                    }
                    Text("\(article.comments.count) comments")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Divider().padding(.horizontal)

                // Comments
                VStack(alignment: .leading, spacing: 12) {
                    Text("Comments")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if article.comments.isEmpty {
                        Text("No comments yet")
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        ForEach(article.comments) { comment in
                            CommentRowView(comment: comment)
                        }
                    }
                }

                // Add Comment
                HStack {
                    TextField("Add a comment...", text: $commentText)
                        .textFieldStyle(.roundedBorder)
                    Button(action: addComment) {
                        Image(systemName: "paperplane.fill")
                    }
                    .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Done") { dismiss() })
    }

    
    private var isLiked: Bool {
        guard let userId = authViewModel.currentUser?.id else { return false }
        return article.likes.contains(userId)
    }
    
    private func toggleLike() {
        guard let userId = authViewModel.currentUser?.id else { return }
        socialViewModel.toggleLike(articleId: article.id, userId: userId)
    }
    
    private func addComment() {
        guard let user = authViewModel.currentUser else { return }
        let text = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        socialViewModel.addComment(
            articleId: article.id,
            userId: user.id,
            userName: user.displayName,
            text: text
        )
        commentText = ""
    }
}

struct CommentRowView: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.userName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(comment.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(comment.text)
                    .font(.body)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
