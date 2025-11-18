//
//  UserArticleRowView.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//


import SwiftUI

struct UserArticleRowView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var socialViewModel: SocialViewModel
    
    let article: UserArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Author info
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.accentColor)
                
                Text(article.authorName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(article.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Image
            if let imageURL = article.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(8)
            }
            
            // Title and Content
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(article.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Actions
            HStack(spacing: 20) {
                Button(action: { toggleLike() }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .primary)
                        Text("\(article.likes.count)")
                            .font(.caption)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                    Text("\(article.comments.count)")
                        .font(.caption)
                }
                .foregroundColor(.primary)
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var isLiked: Bool {
        guard let userId = authViewModel.currentUser?.id else { return false }
        return article.likes.contains(userId)
    }
    
    private func toggleLike() {
        guard let userId = authViewModel.currentUser?.id else { return }
        socialViewModel.toggleLike(articleId: article.id, userId: userId)
    }
}
