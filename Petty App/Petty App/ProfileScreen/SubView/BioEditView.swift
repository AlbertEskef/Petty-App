//
//  BioEditorView.swift
//  Petty App
//
//  Created by AlbertoOoXking on 13.01.25.
//

import SwiftUI

struct BioEditorView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Binding var isEditingBio: Bool
    @State private var bioText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Edit Bio")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Let others know more about you!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                Spacer()
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $bioText)
                        .padding()
                        .frame(height: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)

                    if bioText.isEmpty {
                        Text("Write something about yourself...")
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.horizontal, 30)
                            .padding(.top, 28)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        Task {
                            userViewModel.updateBio(bioText)
                            isEditingBio = false
                        }
                    }) {
                        Text("Save Changes")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.4), radius: 6, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        isEditingBio = false
                    }) {
                        Text("Cancel")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .background(BackgroundView())
            .navigationBarHidden(true)
        }
        .onAppear {
            bioText = userViewModel.user?.bio ?? ""
        }
    }
}
