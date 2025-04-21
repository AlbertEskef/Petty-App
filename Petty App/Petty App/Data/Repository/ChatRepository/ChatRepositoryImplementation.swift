//
//  ChatRepositoryImplementation.swift
//  Petty App
//
//  Created by AlbertoOoXking on 23.01.25.
//

import Foundation
import FirebaseFirestore

class ChatRepositoryImplementation {
    private let fb = FirebaseService.shared

    func ensureChatExistsAndUpdateMetadata(
        chatId: String,
        currentUserEmail: String,
        otherUserEmail: String,
        chatName: String,
        lastMessage: String
    ) async {
        print("ensureChatExists called with:")
        print(" chatId: \(chatId)")
        print(" currentUserEmail: \(currentUserEmail)")
        print(" otherUserEmail: \(otherUserEmail)")
        print(" lastMessage: \(lastMessage)")

        let chatRef = fb.database.collection("chats").document(chatId)

        do {
            let document = try await chatRef.getDocument()
            
            if !document.exists {
                if currentUserEmail == otherUserEmail {
                    print("Cannot create a chat with yourself.")
                    return
                }
                
                let otherUserNickname = await fetchUserNickname(email: otherUserEmail) ?? "Unknown"
                let chat = Chat(
                    id: chatId,
                    members: [currentUserEmail, otherUserEmail],
                    name: chatName,
                    lastMessage: lastMessage,
                    lastUpdated: Date(),
                    otherUserEmail: otherUserEmail,
                    otherUserNickname: otherUserNickname
                )
                
                do {
                    try await chatRef.setData([
                        "id": chat.id ?? chatId,
                        "members": chat.members,
                        "name": chat.name,
                        "lastMessage": chat.lastMessage,
                        "lastUpdated": Timestamp(date: chat.lastUpdated),
                        "otherUserEmail": chat.otherUserEmail,
                        "otherUserNickname": chat.otherUserNickname
                    ])
                    print("Chat created: \(chatId)")
                } catch {
                    print("Error creating chat doc: \(error.localizedDescription)")
                }
                
            } else {
                do {
                    try await chatRef.updateData([
                        "lastMessage": lastMessage,
                        "lastUpdated": Timestamp(date: Date())
                    ])
                    print("Chat updated: \(chatId) with lastMessage: \(lastMessage)")
                } catch {
                    print("Error updating chat doc: \(error.localizedDescription)")
                }
            }
        } catch let error as NSError {
            print("Error in ensureChatExistsAndUpdateMetadata: \(error.localizedDescription)")
        }
    }

    func fetchUserNickname(email: String) async -> String? {
        let userRef = fb.database.collection("users").whereField("email", isEqualTo: email)
        do {
            let snapshot = try await userRef.getDocuments()
            if let document = snapshot.documents.first {
                return document.data()["nickname"] as? String
            }
        } catch {
            print("Error fetching nickname for \(email): \(error.localizedDescription)")
        }
        return nil
    }

    func addChatSnapshotListener(userEmail: String, onSuccess: @escaping ([Chat]) -> Void) -> ListenerRegistration? {
        return fb.database.collection("chats")
            .whereField("members", arrayContains: userEmail)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching chats: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                var chats = documents.compactMap { try? $0.data(as: Chat.self) }

                Task {
                    for i in 0..<chats.count {
                        let otherUserEmail = chats[i].members.first { $0 != userEmail } ?? ""

                        if !otherUserEmail.isEmpty {
                            let nickname = await self?.fetchUserNickname(email: otherUserEmail) ?? "Unknown"
                            chats[i].otherUserNickname = nickname
                        }
                    }
                    DispatchQueue.main.async {
                        onSuccess(chats)
                    }
                }
            }
    }

    func addMessageSnapshotListener(chatID: String, onSuccess: @escaping ([Message]) -> Void) -> ListenerRegistration? {
        return fb.database.collection("chats")
            .document(chatID)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                let messages = documents.compactMap { try? $0.data(as: Message.self) }
                onSuccess(messages)
            }
    }

    func sendMessage(
        chatId: String,
        content: String,
        currentUserEmail: String,
        otherUserEmail: String,
        chatName: String
    ) async {
        guard let senderId = fb.userID else { return }
        let message = Message(content: content, senderID: senderId)

        do {
            await ensureChatExistsAndUpdateMetadata(
                chatId: chatId,
                currentUserEmail: currentUserEmail,
                otherUserEmail: otherUserEmail,
                chatName: chatName,
                lastMessage: content
            )

            let messageRef = fb.database.collection("chats")
                .document(chatId)
                .collection("messages")
                .document()
            try messageRef.setData(from: message)

            print("Message sent with content: '\(content)' from sender: \(senderId)")
        } catch {
            print("Error sending message: \(error)")
        }
    }
}
