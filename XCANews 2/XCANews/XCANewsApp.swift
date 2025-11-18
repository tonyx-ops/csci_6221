//  XCANewsApp.swift

import SwiftUI

@main
struct XCANewsApp: App {
    
    @StateObject var articleBookmarkVM = ArticleBookmarkViewModel.shared
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var socialViewModel = SocialViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(articleBookmarkVM)
                .environmentObject(authViewModel)
                .environmentObject(socialViewModel)
        }
    }
}
