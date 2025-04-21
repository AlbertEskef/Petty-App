//
//  Chat.swift
//  Petty App
//
//  Created by AlbertoOoXking on 23.01.25.
//

import Foundation
import FirebaseFirestore

struct Chat: Codable, Identifiable {
    @DocumentID var id: String?
    var members: [String]
    var name: String
    var lastMessage: String
    var lastUpdated: Date
    var otherUserEmail: String = ""
    var otherUserNickname: String = "" 
}
