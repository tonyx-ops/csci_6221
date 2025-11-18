//
//  XCANewsApp.swift
//  XCANews
//
//  Firebase Integrated Version
//

import SwiftUI
import FirebaseCore

@main
struct XCANewsApp: App {
    
    // Initialize Firebase
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject var articleBookmarkVM = ArticleBookmarkViewModel.shared
    @StateObject var authViewModel = FirebaseAuthViewModel()
    @StateObject var socialViewModel = FirebaseSocialViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(articleBookmarkVM)
                .environmentObject(authViewModel)
                .environmentObject(socialViewModel)
        }
    }
}
