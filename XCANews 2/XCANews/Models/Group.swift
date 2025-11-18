//
//  Group.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//

import Foundation

struct Group: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var description: String
    let creatorId: String
    var members: [String] // Array of user IDs
    var messages: [GroupMessage]
    var sharedArticles: [SharedArticle]
    let createdAt: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         description: String,
         creatorId: String,
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.creatorId = creatorId
        self.members = [creatorId]
        self.messages = []
        self.sharedArticles = []
        self.createdAt = createdAt
    }
}

struct GroupMessage: Codable, Identifiable, Equatable {
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
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

struct SharedArticle: Codable, Identifiable, Equatable {
    let id: String
    let sharedBy: String
    let sharedByName: String
    let articleTitle: String
    let articleURL: String
    let sharedAt: Date
    
    init(id: String = UUID().uuidString,
         sharedBy: String,
         sharedByName: String,
         articleTitle: String,
         articleURL: String,
         sharedAt: Date = Date()) {
        self.id = id
        self.sharedBy = sharedBy
        self.sharedByName = sharedByName
        self.articleTitle = articleTitle
        self.articleURL = articleURL
        self.sharedAt = sharedAt
    }
}
