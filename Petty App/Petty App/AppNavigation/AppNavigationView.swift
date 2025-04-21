//
//  AppNavigationView.swift
//  Petty App
//
//  Created by Albert Eskef on 06.01.25.
//

import SwiftUI

struct AppNavigationView: View {
    
    @State private var selectedTab: Int = 0
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            ChatListView()
                .tabItem {
                    Label("Chats", systemImage: "message.fill")
                }
                .tag(1)
            
            if let userId = userViewModel.user?.id {
                FavoriteView(userId: userId)
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
                    .tag(2)
            } else {
                Text("Please log in to view favorites.")
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
                    .tag(2)
            }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}
