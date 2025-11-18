//
//  UserArticle.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//


import Foundation

struct UserArticle: Codable, Identifiable, Equatable {
    let id: String
    let authorId: String
    let authorName: String
    let title: String
    let content: String
    let imageURL: String?
    let videoURL: String?
    let createdAt: Date
    var likes: [String] // Array of user IDs who liked
    var comments: [Comment]
    
    init(id: String = UUID().uuidString,
         authorId: String,
         authorName: String,
         title: String,
         content: String,
         imageURL: String? = nil,
         videoURL: String? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.title = title
        self.content = content
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.createdAt = createdAt
        self.likes = []
        self.comments = []
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

struct Comment: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let userName: String
    let text: String
    let createdAt: Date
    
    init(id: String = UUID().uuidString,
         userId: String,
         userName: String,
         text: String,
         createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.text = text
        self.createdAt = createdAt
    }
}
