//
//  HomeView.swift
//  Petty App
//
//  Created by Albert Eskef on 06.01.25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel(speciesRepository: SpeciesRepository())
    @StateObject private var userViewModel = UserViewModel()
    @State private var isAddAnimalPresented = false
    @State private var isProfileViewPresented = false
    @State private var didAppearOnce = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                VStack {
                    searchBar
                    categoryTabs
                    animalGrid
                }
                .navigationTitle(userViewModel.user?.nickname ?? "Welcome")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            isProfileViewPresented = true
                        }) {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isAddAnimalPresented = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .sheet(isPresented: $isAddAnimalPresented) {
                    AddAnimalView(viewModel: viewModel, userViewModel: userViewModel)
                }
                .sheet(isPresented: $isProfileViewPresented) {
                    if let loggedInUser = userViewModel.user {
                        ProfileView(
                            viewModel: viewModel,
                            userViewModel: userViewModel,
                            user: loggedInUser,
                            isEditable: true
                        )
                    }
                }
                .onAppear {
                    Task {
                        if !didAppearOnce {
                            didAppearOnce = true
                            await viewModel.loadSpecies()
                            if let firstCategory = viewModel.speciesList.first?.species, viewModel.selectedCategory == nil {
                                viewModel.selectedCategory = firstCategory
                                await viewModel.fetchAllAnimals(for: firstCategory)
                            } else {
                                await viewModel.fetchAllAnimals(for: viewModel.selectedCategory)
                            }
                        }
                        guard let userId = userViewModel.user?.id else { return }
                        viewModel.favoriteAnimals = await viewModel.fetchFavorites(userId: userId)
                    }
                }
                .onChange(of: viewModel.searchText) { oldValue, newValue in
                    print("Search text changed from '\(oldValue)' to '\(newValue)'")
                    viewModel.filterAnimals()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search", text: $viewModel.searchText)
                .padding(10)
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(viewModel.speciesList.map { $0.species }, id: \.self) { category in
                    Button(action: {
                        Task {
                            viewModel.selectedCategory = category
                            await viewModel.fetchAllAnimals(for: category)
                        }
                    }) {
                        Text(category)
                            .fontWeight(viewModel.selectedCategory == category ? .bold : .regular)
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(viewModel.selectedCategory == category ? Color.white.opacity(0.8) : Color.white.opacity(0.3))
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 10)
    }
    
    private var animalGrid: some View {
        ScrollView {
            if viewModel.filteredAnimals.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(viewModel.filteredAnimals) { animal in
                        ZStack(alignment: .topTrailing) {
                            NavigationLink(destination: DetailView(animal: animal)) {
                                AnimalCard(animal: animal)
                            }

                            Button(action: {
                                Task {
                                    guard let userId = userViewModel.user?.id else { return }
                                    if isFavorite(animal: animal) {
                                        await viewModel.removeFavorite(animalId: animal.id!, userId: userId)
                                    } else {
                                        await viewModel.addFavorite(animal: animal, userId: userId)
                                    }
                                    viewModel.favoriteAnimals = await viewModel.fetchFavorites(userId: userId)
                                }
                            }) {
                                Image(systemName: isFavorite(animal: animal) ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .padding(5)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "face.dashed")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.7))

            Text("No animals found!")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.gray)

            Text("Try browsing a different category or add a new animal.")
                .font(.body)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func isFavorite(animal: Animal) -> Bool {
        viewModel.favoriteAnimals.contains(where: { $0.id == animal.id })
    }
}
