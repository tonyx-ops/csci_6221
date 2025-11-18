//
//  UserProfileView.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//


import SwiftUI

struct UserProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var socialViewModel: SocialViewModel
    
    @State private var user: User
    let isOwnProfile: Bool
    
    @State private var showEditProfile = false
    @State private var selectedArticle: UserArticle?
    
    init(user: User, isOwnProfile: Bool) {
           self._user = State(initialValue: user)
           self.isOwnProfile = isOwnProfile
       }
       
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Profile Header
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                    
                    Text(user.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !user.bio.isEmpty {
                        Text(user.bio)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(userArticles.count)")
                                .font(.headline)
                            Text("Articles")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(user.followers.count)")
                                .font(.headline)
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(user.following.count)")
                                .font(.headline)
                            Text("Following")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)
                    
                    if isOwnProfile {
                        Button(action: { showEditProfile = true }) {
                            Text("Edit Profile")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: toggleFollow) {
                            Text(isFollowing ? "Unfollow" : "Follow")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(isFollowing ? Color.gray.opacity(0.2) : Color.accentColor)
                                .foregroundColor(isFollowing ? .primary : .white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                Divider()
                
                // Articles Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Articles")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if userArticles.isEmpty {
                        Text("No articles yet")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    } else {
                        ForEach(userArticles) { article in
                            UserArticleRowView(article: article)
                                .onTapGesture {
                                    selectedArticle = article
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle(isOwnProfile ? "My Profile" : "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(user: user)
        }
        .sheet(item: $selectedArticle) { article in
            ArticleDetailView(articleId: article.id)
        }
        .onAppear {
            refreshUserData()
        }
        .onChange(of: authViewModel.currentUser) { _ in
            refreshUserData()
        }
    }
    
    private var userArticles: [UserArticle] {
        socialViewModel.getArticles(by: user.id)
    }
    
    private var isFollowing: Bool {
        guard let currentUser = authViewModel.currentUser else { return false }
        return socialViewModel.isFollowing(followerId: currentUser.id, followingId: user.id, authViewModel: authViewModel)
    }
    
    private func toggleFollow() {
        guard let currentUser = authViewModel.currentUser else { return }
        
        if isFollowing {
            socialViewModel.unfollowUser(followerId: currentUser.id, followingId: user.id, authViewModel: authViewModel)
        } else {
            socialViewModel.followUser(followerId: currentUser.id, followingId: user.id, authViewModel: authViewModel)
        }
    }
    private func refreshUserData() {
            if let updated = authViewModel.getUser(by: user.id) {
                user = updated
            }
        }
}
