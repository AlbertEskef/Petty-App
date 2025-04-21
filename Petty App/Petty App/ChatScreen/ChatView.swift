//
//  ChatView.swift
//  Petty App
//
//  Created by AlbertoOoXking on 23.01.25.
//


import SwiftUI

struct ChatView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    let chatId: String
    let chatName: String
    let otherUserEmail: String

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            BackgroundView()

            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(chatViewModel.messages) { message in
                                HStack {
                                    if message.senderID == chatViewModel.currentUserID {
                                        Spacer()
                                        messageBubble(
                                            text: message.content,
                                            timestamp: message.timestamp,
                                            isCurrentUser: true
                                        )
                                        .id(message.id)
                                    } else {
                                        messageBubble(
                                            text: message.content,
                                            timestamp: message.timestamp,
                                            isCurrentUser: false
                                        )
                                        .id(message.id)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: chatViewModel.messages) { _, newMessages in
                        if let lastMessageID = newMessages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastMessageID, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        chatViewModel.fetchMessages(chatId: chatId)
                        if let lastMessageID = chatViewModel.messages.last?.id {
                            DispatchQueue.main.async {
                                proxy.scrollTo(lastMessageID, anchor: .bottom)
                            }
                        }
                    }
                    messageInputSection(proxy: proxy)
                }
            }
        }
        .navigationTitle(chatName)
        .navigationBarTitleDisplayMode(.inline)
//        .toolbar(.hidden, for: .tabBar) 
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    @ViewBuilder
    private func messageBubble(text: String, timestamp: Date, isCurrentUser: Bool) -> some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            if isCurrentUser {
                Text(text)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.orange]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(15)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                Text(timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            } else {
                Text(text)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(15)
                    .foregroundColor(.black)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 1, y: 1)
                Text(timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    @ViewBuilder
    private func messageInputSection(proxy: ScrollViewProxy) -> some View {
        HStack {
            TextField("Typing Something", text: $chatViewModel.messageInput)
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 1, y: 1)

            Button(action: {
                if chatViewModel.messageInput.isEmpty {
                    alertMessage = "Message cannot be empty!"
                    showAlert = true
                } else {
                    chatViewModel.sendMessage(
                        chatId: chatId,
                        chatName: chatName,
                        otherUserEmail: otherUserEmail
                    )
                    Task {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        if let lastMessageID = chatViewModel.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastMessageID, anchor: .bottom)
                            }
                        }
                    }
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.orange]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
            }
        }
        .padding()
        .background(Color.clear)
    }
}
