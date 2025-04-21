//
//  ProfileView.swift
//  Petty App
//
//  Created by AlbertoOoXking on 09.01.25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var userViewModel: UserViewModel
    
    let user: FireUser
    let isEditable: Bool
    
    @State private var profileUser: FireUser? = nil
    
    @State private var isEditingBio = false
    @State private var bioText: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var isUploading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                if let profileUser = profileUser {
                    headerSection(for: profileUser)
                    bioSection(for: profileUser)
                    animalsSection(for: profileUser)
                } else {
                    ProgressView("Loading Profile...")
                }
                
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) { _, newImage in
                if let newImage = newImage, let profileUser = profileUser {
                    uploadProfileImage(newImage, for: profileUser)
                }
            }
            .sheet(isPresented: $isEditingBio) {
                BioEditorView(userViewModel: userViewModel, isEditingBio: $isEditingBio)
            }
            .onAppear {
                Task {
                    if !isEditable {
                        do {
                            let doc = try await FirebaseService.shared.database
                                .collection("users")
                                .document(user.id!)
                                .getDocument()
                            
                            if doc.exists {
                                self.profileUser = try doc.data(as: FireUser.self)
                            } else {
                                self.profileUser = user
                            }
                        } catch {
                            print("Error fetching user for profile: \(error.localizedDescription)")
                            self.profileUser = user
                        }
                    } else {
                        self.profileUser = userViewModel.user
                    }
                    
                    await viewModel.fetchUserAnimals(for: user.email)
                }
            }
            .onChange(of: userViewModel.user?.bio) { _ , newBio in
                if isEditable, let newBio = newBio {
                    self.profileUser?.bio = newBio
                }
            }
            .onChange(of: userViewModel.user?.profileImageUrl) { _ , newUrl in
                if isEditable, let newUrl = newUrl {
                    self.profileUser?.profileImageUrl = newUrl
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension ProfileView {
    @ViewBuilder
    private func headerSection(for profileUser: FireUser) -> some View {
        ZStack {
            VStack(spacing: 10) {
                if let imageUrl = profileUser.profileImageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
                    .shadow(radius: 10)
                } else {
                    Image("profilePlaceholder")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .shadow(radius: 10)
                }
                
                if isEditable {
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        Text("Change Photo")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
                
                Text("Hey \(profileUser.nickname)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.top, 50)
        }
        .frame(maxWidth: .infinity)
    }
}

extension ProfileView {
    @ViewBuilder
    private func bioSection(for profileUser: FireUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bio")
                .font(.headline)
                .foregroundColor(.black)
            
            if let bio = profileUser.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.gray)
            } else {
                Text("No bio available")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            if isEditable {
                Button(action: {
                    isEditingBio = true
                    bioText = profileUser.bio ?? ""
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Bio")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

extension ProfileView {
    @ViewBuilder
    private func animalsSection(for profileUser: FireUser) -> some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 2),
                spacing: 20
            ) {
                ForEach(viewModel.userAnimals) { animal in
                    ZStack(alignment: .topTrailing) {
                        NavigationLink(
                            destination: DetailView(animal: animal)
                                .environmentObject(viewModel)
                                .environmentObject(userViewModel)
                        ) {
                            AnimalCard(animal: animal)
                        }
                        
                        if isEditable {
                            Button(action: {
                                Task {
                                    await viewModel.deleteAnimal(animal: animal)
                                    await viewModel.fetchUserAnimals(for: profileUser.email)
                                    await viewModel.refreshCurrentCategoryAnimals()
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding(5)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            .padding(5)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

extension ProfileView {
    private func uploadProfileImage(_ image: UIImage, for profileUser: FireUser) {
        isUploading = true
        FirebaseService.shared.uploadImage(
            image,
            path: "users/\(profileUser.id ?? UUID().uuidString).jpg"
        ) { result in
            switch result {
            case .success(let imageUrl):
                userViewModel.updateProfileImageUrl(imageUrl) {
                    isUploading = false
                }
            case .failure(let error):
                isUploading = false
                print("Failed to upload profile image: \(error.localizedDescription)")
            }
        }
    }
}
