//
//  FireUser.swift
//  Petty App
//
//  Created by Albert Eskef on 03.01.25.
//

import Foundation
import FirebaseFirestore

struct FireUser: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let email: String
    var nickname: String
    let registeredAt: Date
    var address: String?
    var city: String?
    var postalCode: String?
    var profileImageUrl: String?
    var bio: String?
}
