//
//  Petty_AppApp.swift
//  Petty App
//
//  Created by Albert Eskef on 12.12.24.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Petty_AppApp: App {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @State private var showSplash = true
    
    // register app delegate for Firebase setup
     @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreen()
                    .environmentObject(userViewModel)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.showSplash = false
                            }
                        }
                    }
            } else {
                if userViewModel.isUserLoggedIn {
                    AppNavigationView()
                        .environmentObject(homeViewModel)
                        .environmentObject(userViewModel)
                        .preferredColorScheme(.light)
                } else {
                    AuthenticationView()
                        .environmentObject(userViewModel)
                        .preferredColorScheme(.light)
                }
            }
        }
    }
}
