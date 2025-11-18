import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isLoggedIn {
            MainTabView()      // App after login
        } else {
            LoginView()        // Login screen
        }
    }
}
