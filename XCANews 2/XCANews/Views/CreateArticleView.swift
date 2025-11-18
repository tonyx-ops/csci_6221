//
//  CreateArticleView.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//

import SwiftUI

struct CreateArticleView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var socialViewModel: SocialViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var imageURL: String = ""
    @State private var videoURL: String = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                        
                        if content.isEmpty {
                            Text("Write your article content here...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
                } header: {
                    Text("Article Details")
                }
                
                Section {
                    TextField("Image URL", text: $imageURL)
                        .autocapitalization(.none)
                    
                    TextField("Video URL", text: $videoURL)
                        .autocapitalization(.none)
                } header: {
                    Text("Media (Optional)")
                }
                
                Section {
                    Button(action: createArticle) {
                        HStack {
                            Spacer()
                            Text("Publish Article")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .navigationTitle("Create Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Success", isPresented: $showAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your article has been published!")
            }
        }
    }
    
    private func createArticle() {
        guard let user = authViewModel.currentUser else { return }
        
        let trimmedImageURL = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedVideoURL = videoURL.trimmingCharacters(in: .whitespacesAndNewlines)
        
        socialViewModel.createArticle(
            title: title,
            content: content,
            imageURL: trimmedImageURL.isEmpty ? nil : trimmedImageURL,
            videoURL: trimmedVideoURL.isEmpty ? nil : trimmedVideoURL,
            authorId: user.id,
            authorName: user.displayName
        )
        
        showAlert = true
    }
}

struct CreateArticleView_Previews: PreviewProvider {
    static var previews: some View {
        CreateArticleView()
            .environmentObject(AuthViewModel())
            .environmentObject(SocialViewModel.shared)
    }
}
