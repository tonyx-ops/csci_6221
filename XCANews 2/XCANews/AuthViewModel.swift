//
//  AuthViewModel.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 01/11/25.
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var isLoggedIn: Bool
    @Published var errorMessage: String = ""
    @Published var currentUser: User?
    
    private let loggedInKey = "isLoggedIn"
    private let currentUserIdKey = "currentUserId"
    private let usersKey = "registeredUsers"
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: loggedInKey)
        if isLoggedIn {
            loadCurrentUser()
        }
    }
    
    // Register new account
    func register(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return false
        }
        
        // Check if user already exists
        var users = getUsers()
        if users[email] != nil {
            errorMessage = "Account already exists. Please login."
            return false
        }
        
        // Create new user
        let newUser = User(email: email)
        var userProfiles = getUserProfiles()
        userProfiles[newUser.id] = newUser
        saveUserProfiles(userProfiles)
        
        // Save credentials
        users[email] = (password: password, userId: newUser.id)
        saveUsers(users)
        
        errorMessage = ""
        return true
    }
    
    // Login existing account
    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        let users = getUsers()
        
        // Check if account exists
        guard let userData = users[email] else {
            errorMessage = "Account does not exist. Please sign up first."
            return
        }
        
        // Check if password is correct
        guard userData.password == password else {
            errorMessage = "Username or password is incorrect"
            return
        }
        
        // Login successful
        isLoggedIn = true
        UserDefaults.standard.set(true, forKey: loggedInKey)
        UserDefaults.standard.set(userData.userId, forKey: currentUserIdKey)
        loadCurrentUser()
        errorMessage = ""
    }
    
    func logout() {
        isLoggedIn = false
        currentUser = nil
        UserDefaults.standard.set(false, forKey: loggedInKey)
        UserDefaults.standard.removeObject(forKey: currentUserIdKey)
        errorMessage = ""
    }
    
    func updateProfile(displayName: String, bio: String) {
        guard var user = currentUser else { return }
        user.displayName = displayName
        user.bio = bio
        
        var userProfiles = getUserProfiles()
        userProfiles[user.id] = user
        saveUserProfiles(userProfiles)
        
        currentUser = user
    }
    
    private func loadCurrentUser() {
        guard let userId = UserDefaults.standard.string(forKey: currentUserIdKey) else { return }
        let userProfiles = getUserProfiles()
        currentUser = userProfiles[userId]
    }
    
    // Helper methods to manage users
    private func getUsers() -> [String: (password: String, userId: String)] {
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let decoded = try? JSONDecoder().decode([String: UserCredentials].self, from: data) {
            return decoded.mapValues { ($0.password, $0.userId) }
        }
        return [:]
    }
    
    private func saveUsers(_ users: [String: (password: String, userId: String)]) {
        let credentials = users.mapValues { UserCredentials(password: $0.password, userId: $0.userId) }
        if let data = try? JSONEncoder().encode(credentials) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
    
    func getUserProfiles() -> [String: User] {
        if let data = UserDefaults.standard.data(forKey: "userProfiles"),
           let profiles = try? JSONDecoder().decode([String: User].self, from: data) {
            return profiles
        }
        return [:]
    }
    
    func saveUserProfiles(_ profiles: [String: User]) {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: "userProfiles")
        }
    }
    
    func getUser(by id: String) -> User? {
        return getUserProfiles()[id]
    }
    
    func updateFollowing(_ newFollowing: [String]) {
        guard var user = currentUser else { return }
        user.following = newFollowing
        currentUser = user
        var profiles = getUserProfiles()
        profiles[user.id] = user
        saveUserProfiles(profiles)
    }

}

private struct UserCredentials: Codable {
    let password: String
    let userId: String
}
