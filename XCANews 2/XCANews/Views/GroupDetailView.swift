//
//  GroupDetailView.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//


import SwiftUI

struct GroupDetailView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var socialViewModel: SocialViewModel
    
    let group: Group
    
    @State private var selectedTab = 0
    @State private var messageText = ""
    @State private var showShareArticle = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Group Header
            VStack(spacing: 8) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.accentColor)
                
                Text(group.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(group.members.count) members")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !isMember {
                    Button(action: joinGroup) {
                        Text("Join Group")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                } else {
                    Button(action: { }) {
                        Text("Member")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            
            Picker("", selection: $selectedTab) {
                Text("Chat").tag(0)
                Text("Articles").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if isMember {
                if selectedTab == 0 {
                    chatView
                } else {
                    articlesView
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Join the group to see content")
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareArticle) {
            ShareArticleToGroupView(group: group)
        }
    }
    
    private var isMember: Bool {
        guard let userId = authViewModel.currentUser?.id else { return false }
        return group.members.contains(userId)
    }
    
    private var chatView: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if currentGroup?.messages.isEmpty ?? true {
                        Text("No messages yet. Start the conversation!")
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    } else {
                        ForEach(currentGroup?.messages ?? []) { message in
                            MessageRowView(message: message, isCurrentUser: message.userId == authViewModel.currentUser?.id)
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.accentColor)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
    }
    
    private var articlesView: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if currentGroup?.sharedArticles.isEmpty ?? true {
                        Text("No articles shared yet")
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    } else {
                        ForEach(currentGroup?.sharedArticles ?? []) { article in
                            SharedArticleRowView(article: article)
                        }
                    }
                }
                .padding()
            }
            
            Button(action: { showShareArticle = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Share Article")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }
    
    private var currentGroup: Group? {
        socialViewModel.groups.first { $0.id == group.id }
    }
    
    private func joinGroup() {
        guard let userId = authViewModel.currentUser?.id else { return }
        socialViewModel.joinGroup(groupId: group.id, userId: userId)
    }
    
    private func sendMessage() {
        guard let user = authViewModel.currentUser else { return }
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        socialViewModel.sendMessage(
            groupId: group.id,
            userId: user.id,
            userName: user.displayName,
            text: text
        )
        messageText = ""
    }
}

struct MessageRowView: View {
    let message: GroupMessage
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser {
                    Text(message.userName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                }
                
                Text(message.text)
                    .padding(10)
                    .background(isCurrentUser ? Color.accentColor : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(12)
                
                Text(message.timeAgo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
}

struct SharedArticleRowView: View {
    let article: SharedArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.accentColor)
                Text(article.sharedByName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(article.sharedAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(article.articleTitle)
                .font(.headline)
                .lineLimit(2)
            
            if let url = URL(string: article.articleURL) {
                Link("Read Article", destination: url)
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
