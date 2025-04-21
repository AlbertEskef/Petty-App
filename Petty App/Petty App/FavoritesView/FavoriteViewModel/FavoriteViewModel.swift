//
//  FavoriteViewModel.swift
//  Petty App
//
//  Created by AlbertoOoXking on 20.01.25.
//

import Foundation
import FirebaseFirestore

@MainActor
class FavoriteViewModel: ObservableObject {
    @Published var favoriteAnimals: [Animal] = []
    @Published var invalidAnimalIds: Set<String> = []
    
    private let userId: String
    private let firebase = FirebaseService.shared.database

    init(userId: String) {
        self.userId = userId
        Task { await fetchFavorites() }
    }

    func fetchFavorites() async {
        let favoritesRef = firebase.collection("users").document(userId).collection("favorites")
        do {
            let snapshot = try await favoritesRef.getDocuments()
            let animals = snapshot.documents.compactMap { document in
                try? document.data(as: Animal.self)
            }
            self.favoriteAnimals = animals
            await validateAnimals(animals: animals)
        } catch {
            print("Error fetching favorites: \(error)")
        }
    }

    private func validateAnimals(animals: [Animal]) async {
        invalidAnimalIds = []
        let animalCollection = firebase.collection("animals")
        
        for animal in animals {
            guard let animalId = animal.id else { continue }
            do {
                let document = try await animalCollection.document(animalId).getDocument()
                if !document.exists {
                    invalidAnimalIds.insert(animalId) 
                }
            } catch {
                print("Error validating animal \(animalId): \(error)")
            }
        }
    }

    func removeFavorite(animalId: String) async {
        let favoritesRef = firebase.collection("users").document(userId).collection("favorites")
        do {
            try await favoritesRef.document(animalId).delete()
            self.favoriteAnimals.removeAll { $0.id == animalId }
            self.invalidAnimalIds.remove(animalId)
        } catch {
            print("Error removing favorite: \(error)")
        }
    }
}
