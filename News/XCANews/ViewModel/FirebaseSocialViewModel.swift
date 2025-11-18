//
//  FirebaseSocialViewModel.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 17/11/25.
//


//
//  FirebaseSocialViewModel.swift
//  XCANews
//
//  WITHOUT Firebase Storage - Uses Local Storage
//

import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class FirebaseSocialViewModel: ObservableObject {
    
    @Published var userArticles: [UserArticle] = []
    @Published var groups: [Group] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private var articlesListener: ListenerRegistration?
    private var groupsListener: ListenerRegistration?
    
    static let shared = FirebaseSocialViewModel()
    
    private init() {
        setupListeners()
    }
    
    // MARK: - Real-time Listeners
    
    func setupListeners() {
        // Listen for articles changes
        articlesListener = db.collection("articles")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching articles: \(error)")
                    return
                }
                
                self.userArticles = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: UserArticle.self)
                } ?? []
            }
        
        // Listen for groups changes
        groupsListener = db.collection("groups")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching groups: \(error)")
                    return
                }
                
                self.groups = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Group.self)
                } ?? []
            }
    }
    
    deinit {
        articlesListener?.remove()
        groupsListener?.remove()
    }
    
    // MARK: - Articles (Local Storage for Images)
    
    func createArticle(
        title: String,
        content: String,
        image: UIImage?,
        videoURL: String?,
        authorId: String,
        authorName: String
    ) async {
        isLoading = true
        
        do {
            var imageURL: String? = nil
            var isLocalMedia = false
            
            // Save image locally if provided
            if let image = image {
                if let filename = MediaManager.shared.saveImage(image) {
                    imageURL = filename
                    isLocalMedia = true
                }
            }
            
            let article = UserArticle(
                authorId: authorId,
                authorName: authorName,
                title: title,
                content: content,
                imageURL: imageURL,
                videoURL: videoURL,
                isLocalMedia: isLocalMedia
            )
            
            try db.collection("articles").document(article.id ?? UUID().uuidString).setData(from: article)
            
        } catch {
            print("Error creating article: \(error)")
        }
        
        isLoading = false
    }
    
    func getArticles(by authorId: String) -> [UserArticle] {
        return userArticles.filter { $0.authorId == authorId }
    }
    
    func getFollowingArticles(followingIds: [String]) -> [UserArticle] {
        return userArticles.filter { followingIds.contains($0.authorId) }
    }
    
    func toggleLike(articleId: String, userId: String) {
        guard let index = userArticles.firstIndex(where: { $0.id == articleId }) else { return }
        
        let articleRef = db.collection("articles").document(articleId)
        
        if userArticles[index].likes.contains(userId) {
            // Unlike
            articleRef.updateData([
                "likes": FieldValue.arrayRemove([userId])
            ])
        } else {
            // Like
            articleRef.updateData([
                "likes": FieldValue.arrayUnion([userId])
            ])
        }
    }
    
    func addComment(articleId: String, userId: String, userName: String, text: String) {
        let comment = Comment(userId: userId, userName: userName, text: text)
        
        guard let commentData = try? Firestore.Encoder().encode(comment) else { return }
        
        db.collection("articles").document(articleId).updateData([
            "comments": FieldValue.arrayUnion([commentData])
        ])
    }
    
    func deleteArticle(articleId: String) async {
        // Get article to check for local image
        if let article = userArticles.first(where: { $0.id == articleId }),
           article.isLocalMedia,
           let imageFilename = article.imageURL {
            // Delete local image
            MediaManager.shared.deleteImage(filename: imageFilename)
        }
        
        // Delete article document
        do {
            try await db.collection("articles").document(articleId).delete()
        } catch {
            print("Error deleting article: \(error)")
        }
    }
    
    // MARK: - Groups
    
    func createGroup(name: String, description: String, creatorId: String) {
        let group = Group(name: name, description: description, creatorId: creatorId)
        
        do {
            try db.collection("groups").document(group.id ?? UUID().uuidString).setData(from: group)
        } catch {
            print("Error creating group: \(error)")
        }
    }
    
    func joinGroup(groupId: String, userId: String) {
        db.collection("groups").document(groupId).updateData([
            "members": FieldValue.arrayUnion([userId])
        ])
    }
    
    func leaveGroup(groupId: String, userId: String) {
        db.collection("groups").document(groupId).updateData([
            "members": FieldValue.arrayRemove([userId])
        ])
    }
    
    func sendMessage(groupId: String, userId: String, userName: String, text: String) {
        let message = GroupMessage(userId: userId, userName: userName, text: text)
        
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        db.collection("groups").document(groupId).updateData([
            "messages": FieldValue.arrayUnion([messageData])
        ])
    }
    
    func shareArticle(groupId: String, userId: String, userName: String, articleTitle: String, articleURL: String) {
        let sharedArticle = SharedArticle(
            sharedBy: userId,
            sharedByName: userName,
            articleTitle: articleTitle,
            articleURL: articleURL
        )
        
        guard let articleData = try? Firestore.Encoder().encode(sharedArticle) else { return }
        
        db.collection("groups").document(groupId).updateData([
            "sharedArticles": FieldValue.arrayUnion([articleData])
        ])
    }
    
    func getUserGroups(userId: String) -> [Group] {
        return groups.filter { $0.members.contains(userId) }
    }
    
    func deleteGroup(groupId: String) async {
        do {
            try await db.collection("groups").document(groupId).delete()
        } catch {
            print("Error deleting group: \(error)")
        }
    }
}
