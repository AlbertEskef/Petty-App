//
//  FavoriteView.swift
//  Petty App
//
//  Created by AlbertoOoXking on 20.01.25.
//

import SwiftUI

struct FavoriteView: View {
    @StateObject private var favoriteViewModel: FavoriteViewModel
    @EnvironmentObject var userViewModel: UserViewModel

    init(userId: String) {
        _favoriteViewModel = StateObject(wrappedValue: FavoriteViewModel(userId: userId))
    }
    
    private var validAnimals: [Animal] {
        favoriteViewModel.favoriteAnimals.filter { !favoriteViewModel.invalidAnimalIds.contains($0.id ?? "") }
    }

    private var invalidAnimals: [Animal] {
        favoriteViewModel.favoriteAnimals.filter { favoriteViewModel.invalidAnimalIds.contains($0.id ?? "") }
    }

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()

                VStack {
                    if favoriteViewModel.favoriteAnimals.isEmpty {
                        emptyStateView
                    } else {
                        List {
                            if !validAnimals.isEmpty {
                                Section(header: Text("Valid Favorites").font(.headline)) {
                                    ForEach(validAnimals) { animal in
                                        NavigationLink(destination: DetailView(animal: animal)) {
                                            HStack(spacing: 10) {
                                                AsyncImage(url: URL(string: animal.imageUrl)) { image in
                                                    image.resizable()
                                                } placeholder: {
                                                    Color.gray
                                                }
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())

                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(animal.name)
                                                        .font(.headline)
                                                    Text(animal.species)
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        }
                                    }
                                    .onDelete { indexSet in
                                        handleDelete(at: indexSet, isInvalid: false)
                                    }
                                }
                            }

                            if !invalidAnimals.isEmpty {
                                Section(header: Text("Invalid Favorites").font(.headline)) {
                                    ForEach(invalidAnimals) { animal in
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("This animal is no longer valid.")
                                                .foregroundColor(.red)
                                                .font(.footnote)

                                            HStack(spacing: 10) {
                                                AsyncImage(url: URL(string: animal.imageUrl)) { image in
                                                    image.resizable()
                                                } placeholder: {
                                                    Color.gray
                                                }
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())

                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(animal.name)
                                                        .font(.headline)
                                                    Text(animal.species)
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        }
                                    }
                                    .onDelete { indexSet in
                                        handleDelete(at: indexSet, isInvalid: true)
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("Favorites")
            .onAppear {
                Task { await favoriteViewModel.fetchFavorites() }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.7))

            Text("No favorites yet!")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.gray)

            Text("Browse animals and add them to your favorites.")
                .font(.body)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
    }

    private func handleDelete(at indexSet: IndexSet, isInvalid: Bool) {
        Task {
            if let index = indexSet.first {
                let animalToDelete = isInvalid ? invalidAnimals[index] : validAnimals[index]
                await favoriteViewModel.removeFavorite(animalId: animalToDelete.id ?? "")
            }
        }
    }
}
