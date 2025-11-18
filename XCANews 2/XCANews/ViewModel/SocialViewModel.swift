
//
//  SocialViewModel.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//

import Foundation
import SwiftUI

@MainActor
class SocialViewModel: ObservableObject {
    
    @Published var userArticles: [UserArticle] = []
    @Published var groups: [Group] = []
    
    private let articlesKey = "userArticles"
    private let groupsKey = "groups"
    
    static let shared = SocialViewModel()
    
    private init() {
        loadArticles()
        loadGroups()
    }
    
    // MARK: - Articles
    
    func createArticle(title: String, content: String, imageURL: String?, videoURL: String?, authorId: String, authorName: String) {
        let article = UserArticle(
            authorId: authorId,
            authorName: authorName,
            title: title,
            content: content,
            imageURL: imageURL,
            videoURL: videoURL
        )
        userArticles.insert(article, at: 0)
        saveArticles()
    }
    
    func getArticles(by authorId: String) -> [UserArticle] {
        return userArticles.filter { $0.authorId == authorId }
    }
    
    func getFollowingArticles(followingIds: [String]) -> [UserArticle] {
        return userArticles.filter { followingIds.contains($0.authorId) }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func toggleLike(articleId: String, userId: String) {
        guard let index = userArticles.firstIndex(where: { $0.id == articleId }) else { return }
        
        if userArticles[index].likes.contains(userId) {
            userArticles[index].likes.removeAll { $0 == userId }
        } else {
            userArticles[index].likes.append(userId)
        }
        saveArticles()
    }
    
    func addComment(articleId: String, userId: String, userName: String, text: String) {
        guard let index = userArticles.firstIndex(where: { $0.id == articleId }) else { return }
        
        let comment = Comment(userId: userId, userName: userName, text: text)
        userArticles[index].comments.append(comment)
        saveArticles()
    }
    
    func deleteArticle(articleId: String) {
        userArticles.removeAll { $0.id == articleId }
        saveArticles()
    }
    
    // MARK: - Groups
    
    func createGroup(name: String, description: String, creatorId: String) {
        let group = Group(name: name, description: description, creatorId: creatorId)
        groups.append(group)
        saveGroups()
    }
    
    func joinGroup(groupId: String, userId: String) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }
        
        if !groups[index].members.contains(userId) {
            groups[index].members.append(userId)
            saveGroups()
        }
    }
    
    func leaveGroup(groupId: String, userId: String) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }
        groups[index].members.removeAll { $0 == userId }
        saveGroups()
    }
    
    func sendMessage(groupId: String, userId: String, userName: String, text: String) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }
        
        let message = GroupMessage(userId: userId, userName: userName, text: text)
        groups[index].messages.append(message)
        saveGroups()
    }
    
    func shareArticle(groupId: String, userId: String, userName: String, articleTitle: String, articleURL: String) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }
        
        let sharedArticle = SharedArticle(
            sharedBy: userId,
            sharedByName: userName,
            articleTitle: articleTitle,
            articleURL: articleURL
        )
        groups[index].sharedArticles.append(sharedArticle)
        saveGroups()
    }
    
    func getUserGroups(userId: String) -> [Group] {
        return groups.filter { $0.members.contains(userId) }
    }
    
    func deleteGroup(groupId: String) {
        groups.removeAll { $0.id == groupId }
        saveGroups()
    }
    
    // MARK: - Following System
    
    func followUser(followerId: String, followingId: String, authViewModel: AuthViewModel) {
        var profiles = authViewModel.getUserProfiles()
        
        if var follower = profiles[followerId] {
            if !follower.following.contains(followingId) {
                follower.following.append(followingId)
            }
            profiles[followerId] = follower
            if followerId == authViewModel.currentUser?.id {
                authViewModel.updateFollowing(follower.following)
            }
        }
        
        if var following = profiles[followingId] {
            if !following.followers.contains(followerId) {
                following.followers.append(followerId)
            }
            profiles[followingId] = following
        }
        
        authViewModel.saveUserProfiles(profiles)
    }
    
    func unfollowUser(followerId: String, followingId: String, authViewModel: AuthViewModel) {
        var profiles = authViewModel.getUserProfiles()
        
        if var follower = profiles[followerId] {
            follower.following.removeAll { $0 == followingId }
            profiles[followerId] = follower
            
            if followerId == authViewModel.currentUser?.id {
                authViewModel.updateFollowing(follower.following)
            }
        }
        
        if var following = profiles[followingId] {
            following.followers.removeAll { $0 == followerId }
            profiles[followingId] = following
        }
        
        authViewModel.saveUserProfiles(profiles)
    }
    
    func isFollowing(followerId: String, followingId: String, authViewModel: AuthViewModel) -> Bool {
        guard let user = authViewModel.getUser(by: followerId) else { return false }
        return user.following.contains(followingId)
    }
    
    // MARK: - Persistence
    
    private func loadArticles() {
        if let data = UserDefaults.standard.data(forKey: articlesKey),
           let articles = try? JSONDecoder().decode([UserArticle].self, from: data) {
            userArticles = articles
        }
    }
    
    private func saveArticles() {
        if let data = try? JSONEncoder().encode(userArticles) {
            UserDefaults.standard.set(data, forKey: articlesKey)
        }
    }
    
    private func loadGroups() {
        if let data = UserDefaults.standard.data(forKey: groupsKey),
           let savedGroups = try? JSONDecoder().decode([Group].self, from: data) {
            groups = savedGroups
        }
    }
    
    private func saveGroups() {
        if let data = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(data, forKey: groupsKey)
        }
    }
}
