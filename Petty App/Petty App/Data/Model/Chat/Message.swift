//
//  Message.swift
//  Petty App
//
//  Created by AlbertoOoXking on 23.01.25.
//

import Foundation
import FirebaseFirestore

struct Message: Codable, Identifiable, Equatable { 
    @DocumentID var id: String?
    var content: String
    var senderID: String
    var timestamp: Date = Date()
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
               lhs.content == rhs.content &&
               lhs.senderID == rhs.senderID &&
               lhs.timestamp == rhs.timestamp
    }
}
