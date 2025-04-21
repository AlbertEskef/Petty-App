//
//  Animal.swift
//  Petty App
//
//  Created by Albert Eskef on 06.01.25.
//

import Foundation
import FirebaseFirestore

struct Animal: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var species: String
    var gender: String?
    var weight: Double?
    var birthday: String?
    var imageUrl: String
    var insuranceProvider: String?
    var policyNumber: String?
    var email: String
}
