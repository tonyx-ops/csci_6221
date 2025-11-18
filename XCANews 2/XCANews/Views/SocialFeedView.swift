//
//  SocialFeedView.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//


import SwiftUI

struct SocialFeedView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var socialViewModel: SocialViewModel
    
    @State private var showCreateArticle = false
    @State private var selectedArticle: UserArticle?
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            if searchText.isEmpty {
                // 正常的 Social Feed
                ScrollView {
                    VStack(spacing: 16) {
                        
                        if !followingArticles.isEmpty {
                            ForEach(followingArticles) { article in
                                UserArticleRowView(article: article)
                                    .onTapGesture {
                                        selectedArticle = article
                                    }
                            }
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "person.2.slash")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No articles yet")
                                    .font(.headline)
                                
                                Text("Follow users to see their articles here")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 100)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Social Feed")
                .navigationBarItems(trailing: Button(action: {
                    showCreateArticle = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                })
                .sheet(isPresented: $showCreateArticle) {
                    CreateArticleView()
                }
                .sheet(item: $selectedArticle) { article in
                    ArticleDetailView(articleId: article.id)
                }
            } else {
                // 搜索模式
                UserSearchResultsView(searchText: searchText)
                    .navigationTitle("Search Results")
            }
        }
        .searchable(text: $searchText, prompt: "Search users...")
    }

    
    private var followingArticles: [UserArticle] {
        guard let currentUser = authViewModel.currentUser else { return [] }
        return socialViewModel.getFollowingArticles(followingIds: currentUser.following)
    }
}

struct UserSearchResultsView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let searchText: String
    
    var body: some View {

            List(filteredUsers) { user in
                NavigationLink(destination: UserProfileView(user: user, isOwnProfile: user.id == authViewModel.currentUser?.id)) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                        
                        VStack(alignment: .leading) {
                            Text(user.displayName)
                                .font(.headline)
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
    }
    
    private var filteredUsers: [User] {
        let profiles = authViewModel.getUserProfiles()
        let query = searchText.lowercased()
        
        return profiles.values.filter { user in
            user.id != authViewModel.currentUser?.id &&
            (user.displayName.lowercased().contains(query) ||
             user.email.lowercased().contains(query))
        }
        .sorted { $0.displayName < $1.displayName }
    }
}
