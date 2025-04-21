//
//  ChatViewModel.swift
//  Petty App
//
//  Created by AlbertoOoXking on 23.01.25.
//

import SwiftUI
import FirebaseFirestore


class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var messageInput: String = ""
    @Published var chats: [Chat] = []
    @Published var currentUserEmail: String?
    @Published var navigatedFromDetailView: Bool = false

    var currentChatId: String?
    private let repo = ChatRepositoryImplementation()
    private var listener: ListenerRegistration?
    private let fb = FirebaseService.shared

    var currentUserID: String {
        FirebaseService.shared.userID ?? ""
    }

    init() {
        fetchCurrentUserEmail()
    }

    deinit {
        stopListening()
    }

    func fetchCurrentUserEmail() {
        if let email = fb.auth.currentUser?.email {
            self.currentUserEmail = email
        } else {
            print("Error: Current user email is not available.")
        }
    }

    func addChatSnapshotListener() {
        guard let currentUserEmail = currentUserEmail else { return }

        listener = repo.addChatSnapshotListener(userEmail: currentUserEmail) { [weak self] chats in
            DispatchQueue.main.async {
                self?.chats = chats.sorted { $0.lastUpdated > $1.lastUpdated }
            }
        }
    }

    func setupChat(animalName: String, otherUserEmail: String) async {
        guard let currentUserEmail = currentUserEmail else {
            print("No currentUserEmail found. Make sure user is logged in.")
            return
        }

        let chatId = generateChatId(
            currentUserEmail: currentUserEmail,
            recipientEmail: otherUserEmail
        )
        self.currentChatId = chatId

        fetchMessages(chatId: chatId)
    }

    func fetchMessages(chatId: String) {
        stopListening()
        listener = repo.addMessageSnapshotListener(chatID: chatId) { [weak self] messages in
            DispatchQueue.main.async {
                self?.messages = messages.sorted { $0.timestamp < $1.timestamp }
            }
        }
    }

    func sendMessage(chatId: String, chatName: String, otherUserEmail: String) {
        guard let currentUserEmail = currentUserEmail,
              !messageInput.isEmpty else {
            return
        }
        Task {
            await repo.ensureChatExistsAndUpdateMetadata(
                chatId: chatId,
                currentUserEmail: currentUserEmail,
                otherUserEmail: otherUserEmail,
                chatName: chatName,
                lastMessage: messageInput
            )

            await repo.sendMessage(
                chatId: chatId,
                content: messageInput,
                currentUserEmail: currentUserEmail,
                otherUserEmail: otherUserEmail,
                chatName: chatName
            )
            DispatchQueue.main.async {
                self.messageInput = ""
            }
        }
    }

    func generateChatId(currentUserEmail: String, recipientEmail: String) -> String {
        [currentUserEmail, recipientEmail].sorted().joined(separator: "_")
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
