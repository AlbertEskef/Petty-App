//
//  DetailView.swift
//  Petty App
//
//  Created by AlbertoOoXking on 08.01.25.
//

import SwiftUI

struct DetailView: View {
    let animal: Animal
    @State private var owner: FireUser? = nil
    @State private var showInfo = false
    @State private var showProfile = false
    @State private var navigateToChatList = false
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var chatViewModel = ChatViewModel()
    
    @State private var showChatSheet = false
    
    @State private var showOwnerMessage = false
    
    var body: some View {
        ZStack {
            VStack {
                ZStack(alignment: .bottomLeading) {
                    if let url = URL(string: animal.imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 300, height: 200)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 300, height: 200)
                        }
                    } else {
                        Image("placeholder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 200)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
                    }
                    
                    if let owner = owner,
                       let profileImageUrl = owner.profileImageUrl,
                       let url = URL(string: profileImageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 80, height: 80)
                        }
                        .offset(x: 16, y: 40)
                        .onTapGesture {
                            showProfile = true
                        }
                    } else {
                        Image("profilePlaceholder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
                            .offset(x: 16, y: 40)
                            .onTapGesture {
                                showProfile = true
                            }
                    }
                }
                .padding(.bottom, 20)
                
                Form {
                    HStack {
                        Label("Nickname", systemImage: "pawprint.fill")
                        Spacer()
                        Text(animal.name)
                    }
                    HStack {
                        Label("Birthday", systemImage: "birthday.cake.fill")
                        Spacer()
                        Text(animal.birthday ?? "Unknown")
                    }
                    HStack {
                        Label("Species", systemImage: "hare.fill")
                        Spacer()
                        Text(animal.species)
                        Button(action: {
                            showInfo = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    HStack {
                        Label("Weight", systemImage: "scalemass.fill")
                        Spacer()
                        Text("\(String(format: "%.2f", animal.weight ?? 0)) kg")
                    }
                    HStack {
                        Label("Sex", systemImage: "person.fill")
                        Spacer()
                        Text(animal.gender ?? "Unknown")
                    }
                    Section(header: Text("Insurance").font(.headline)) {
                        HStack {
                            Label("Provider", systemImage: "house.fill")
                            Spacer()
                            Text(animal.insuranceProvider ?? "None")
                        }
                        HStack {
                            Label("Policy", systemImage: "doc.fill")
                            Spacer()
                            Text(animal.policyNumber ?? "None")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .padding(.bottom, 60)
            }
            
            VStack {
                Spacer()
                Button(action: contactOwnerButtonTapped) {
                    Text("Contact Owner")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            
            NavigationLink(
                destination: ChatListView(
                    autoNavigateToChatId: chatViewModel.currentChatId
                ),
                isActive: $navigateToChatList
            ) {
                EmptyView()
            }
            
            if showOwnerMessage {
                VStack {
                    Spacer()
                    Text("You are the owner of this animal.")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showOwnerMessage = false
                        }
                    }
                }
            }
        }
        .toolbar(.visible, for: .tabBar)
        .background(BackgroundView())
        .navigationTitle(animal.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showInfo) {
            SpeciesInfoView(species: animal.species)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showProfile) {
            if let owner = owner {
                ProfileView(
                    viewModel: viewModel,
                    userViewModel: userViewModel,
                    user: owner,
                    isEditable: false
                )
            }
        }
        .sheet(isPresented: $showChatSheet) {
            NavigationView {
                ChatView(
                    chatViewModel: chatViewModel,
                    chatId: chatViewModel.currentChatId ?? "",
                    chatName: animal.name,
                    otherUserEmail: animal.email
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showChatSheet = false
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchOwnerProfile()
        }
    }
        
    private func contactOwnerButtonTapped() {
        if userViewModel.user?.email == animal.email {
            withAnimation {
                showOwnerMessage = true
            }
        } else {
            Task {
                await chatViewModel.setupChat(
                    animalName: animal.name,
                    otherUserEmail: animal.email
                )
                showChatSheet = true
            }
        }
    }

    private func fetchOwnerProfile() {
        let ownerEmail = animal.email
        Task {
            do {
                let ownerDocument = try await FirebaseService.shared.database
                    .collection("users")
                    .whereField("email", isEqualTo: ownerEmail)
                    .getDocuments()
                if let document = ownerDocument.documents.first {
                    self.owner = try document.data(as: FireUser.self)
                }
            } catch {
                print("Failed to fetch owner profile: \(error.localizedDescription)")
            }
        }
    }
}
