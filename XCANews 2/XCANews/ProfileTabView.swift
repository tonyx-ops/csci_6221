//
//  ProfileTabView.swift
//  XCANews
//
//  Created by Hardhiq Choudhary on 01/11/25.
//

import SwiftUI

struct ProfileTabView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            if let currentUser = authViewModel.currentUser {
                UserProfileView(user: currentUser, isOwnProfile: true)
                    .navigationBarItems(trailing: logoutButton)
            } else {
                Text("Loading...")
            }
        }
    }
    
    private var logoutButton: some View {
        Button(role: .destructive, action: {
            authViewModel.logout()
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Logout")
            }
        }
    }
}
