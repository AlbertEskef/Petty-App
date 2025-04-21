//
//  ChatListView.swift
//  Petty App
//
//  Created by AlbertoOoXking on 23.01.25.
//

import SwiftUI

struct ChatListView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    var autoNavigateToChatId: String? = nil
    @State private var navigateToChatId: String? = nil

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()

                VStack(spacing: 10) {
                    Text("Chats")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                        .padding(.top, 20)

                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(chatViewModel.chats) { chat in
                                NavigationLink(
                                    destination: ChatView(
                                        chatViewModel: chatViewModel,
                                        chatId: chat.id ?? "",
                                        chatName: chat.otherUserNickname,
                                        otherUserEmail: chat.otherUserEmail
                                    ),
                                    tag: chat.id ?? "",
                                    selection: $navigateToChatId
                                ) {
                                    chatRow(for: chat)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }
                }
            }
            .onAppear {
                chatViewModel.addChatSnapshotListener()
                if let autoChatId = autoNavigateToChatId {
                    Task {
                        try await Task.sleep(nanoseconds: 500_000_000)
                        self.navigateToChatId = autoChatId
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    private func chatRow(for chat: Chat) -> some View {
        HStack(spacing: 15) {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange.opacity(0.7), Color.orange]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text(chat.otherUserNickname.prefix(1))
                        .font(.headline)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(chat.otherUserNickname)
                    .font(.headline)
                    .foregroundColor(.blue)

                Text(chat.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }

            Spacer()

            Text(chat.lastUpdated, style: .time)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.customBackgroundColor3.opacity(0.85))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
