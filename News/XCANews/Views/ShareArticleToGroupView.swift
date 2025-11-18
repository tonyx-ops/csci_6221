//
//  ShareArticleToGroupView.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//


//
//  ShareArticleToGroupView.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 16/11/25.
//

import SwiftUI

struct ShareArticleToGroupView: View {
    
    @EnvironmentObject var FirebaseAuthViewModel: FirebaseAuthViewModel
    @EnvironmentObject var FirebaseSocialViewModel: FirebaseSocialViewModel
    @Environment(\.dismiss) var dismiss
    
    let group: Group
    
    @State private var articleTitle: String = ""
    @State private var articleURL: String = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Article Information")) {
                    TextField("Article Title", text: $articleTitle)
                    
                    TextField("Article URL", text: $articleURL)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                }
                
                Section {
                    Button(action: shareArticle) {
                        HStack {
                            Spacer()
                            Text("Share to Group")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(articleTitle.isEmpty || articleURL.isEmpty)
                }
            }
            .navigationTitle("Share Article")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
            .alert("Success", isPresented: $showAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Article shared to \(group.name)!")
            }
        }
    }
    
    private func shareArticle() {
        guard let user = FirebaseAuthViewModel.currentUser,
              let groupId = group.id,
              let userId = user.id else { return }
        
        FirebaseSocialViewModel.shareArticle(
            groupId: groupId,
            userId: userId,
            userName: user.displayName,
            articleTitle: articleTitle,
            articleURL: articleURL
        )
        
        showAlert = true
    }
}
