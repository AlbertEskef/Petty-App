//
//  HomeViewModel.swift
//  Petty App
//
//  Created by Albert Eskef on 06.01.25.
//

import Foundation
import FirebaseFirestore

@MainActor
class HomeViewModel: ObservableObject {
    @Published var animals: [Animal] = []
    @Published var userAnimals: [Animal] = []
    @Published var filteredAnimals: [Animal] = []
    @Published var speciesList: [Species] = []
    @Published var favoriteAnimals: [Animal] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String? = nil

    private let db = FirebaseService.shared.database
    private let speciesRepository: SpeciesRepository

    init(speciesRepository: SpeciesRepository = SpeciesRepository()) {
        self.speciesRepository = speciesRepository
        Task {
            await loadSpecies()
        }
    }

    func loadSpecies() async {
        do {
            let fetchedSpecies = try await speciesRepository.fetchSpecies()
            self.speciesList = fetchedSpecies
            print("Loaded species: \(fetchedSpecies.map { $0.species })")
        } catch {
            print("Error fetching species: \(error.localizedDescription)")
        }
    }

    func fetchAllAnimals(for category: String?) async {
        do {
            print("Fetching all animals for category: \(category ?? "All")")

            var query: Query = db.collection("animals")
            if let category = category {
                query = query.whereField("species", isEqualTo: category)
            }

            let querySnapshot = try await query.getDocuments()
            print("Fetched \(querySnapshot.documents.count) documents from Firestore.")

            let fetchedAnimals = querySnapshot.documents.compactMap { document -> Animal? in
                do {
                    let animal = try document.data(as: Animal.self)
                    print("Decoded animal: \(animal.name), Species: \(animal.species)")
                    return animal
                } catch {
                    print("Error decoding document: \(error.localizedDescription)")
                    return nil
                }
            }

            print("Decoded \(fetchedAnimals.count) animals.")
            self.animals = fetchedAnimals
            self.filterAnimals()

        } catch {
            print("Error fetching all animals: \(error.localizedDescription)")
        }
    }

    func fetchUserAnimals(for userEmail: String) async {
        do {
            print("Fetching animals for user: \(userEmail)")

            let query = db.collection("animals").whereField("email", isEqualTo: userEmail)
            let querySnapshot = try await query.getDocuments()
            print("Fetched \(querySnapshot.documents.count) documents for user.")

            let fetchedAnimals = querySnapshot.documents.compactMap { document -> Animal? in
                do {
                    let animal = try document.data(as: Animal.self)
                    print("Decoded user animal: \(animal.name), Species: \(animal.species)")
                    return animal
                } catch {
                    print("Error decoding document: \(error.localizedDescription)")
                    return nil
                }
            }

            print("Decoded \(fetchedAnimals.count) user animals.")
            self.userAnimals = fetchedAnimals

        } catch {
            print("Error fetching user animals: \(error.localizedDescription)")
        }
    }

    func filterAnimals() {
        filteredAnimals = animals.filter { animal in
            let matchesCategory = selectedCategory == nil || animal.species == selectedCategory
            let matchesSearchText = searchText.isEmpty || animal.name.lowercased().contains(searchText.lowercased())
            return matchesCategory && matchesSearchText
        }
        print("Filtered \(filteredAnimals.count) animals based on search and category.")
    }
    
    func deleteAnimal(animal: Animal) async {
        guard let animalID = animal.id else {
            print("Animal ID is missing. Cannot delete.")
            return
        }

        do {
            try await db.collection("animals").document(animalID).delete()
            print("Animal deleted successfully.")

            await fetchUserAnimals(for: animal.email)
            
            await refreshCurrentCategoryAnimals()

        } catch {
            print("Error deleting animal: \(error.localizedDescription)")
        }
    }

    func saveNewAnimal(animal: Animal, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try db.collection("animals").addDocument(from: animal) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                Task {
                    await self.fetchAllAnimals(for: self.selectedCategory)
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func refreshCurrentCategoryAnimals() async {
        if let category = selectedCategory {
            await fetchAllAnimals(for: category)
        }
    }
}

extension HomeViewModel {
    func addFavorite(animal: Animal, userId: String) async {
        let favoritesRef = FirebaseService.shared.database.collection("users")
            .document(userId)
            .collection("favorites")

        do {
            let animalData = try Firestore.Encoder().encode(animal)
            try await favoritesRef.document(animal.id!).setData(animalData)
            print("Animal added to favorites: \(animal.name)")
        } catch {
            print("Error adding favorite: \(error)")
        }
    }

    func removeFavorite(animalId: String, userId: String) async {
        let favoritesRef = FirebaseService.shared.database.collection("users")
            .document(userId)
            .collection("favorites")

        do {
            try await favoritesRef.document(animalId).delete()
            print("Animal removed from favorites.")
        } catch {
            print("Error removing favorite: \(error)")
        }
    }

    func fetchFavorites(userId: String) async -> [Animal] {
        let favoritesRef = FirebaseService.shared.database.collection("users")
            .document(userId)
            .collection("favorites")
        
        do {
            let snapshot = try await favoritesRef.getDocuments()
            return snapshot.documents.compactMap { document in
                try? document.data(as: Animal.self)
            }
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }
}
