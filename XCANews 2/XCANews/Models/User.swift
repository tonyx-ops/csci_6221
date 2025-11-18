//
//  User.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//


import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    var displayName: String
    var bio: String
    var profileImageURL: String?
    var followers: [String] // Array of user IDs
    var following: [String] // Array of user IDs
    
    init(id: String = UUID().uuidString, email: String, displayName: String = "", bio: String = "") {
        self.id = id
        self.email = email
        self.displayName = displayName.isEmpty ? email.components(separatedBy: "@").first ?? email : displayName
        self.bio = bio
        self.followers = []
        self.following = []
    }
}
