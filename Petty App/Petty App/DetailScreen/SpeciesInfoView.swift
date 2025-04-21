//
//  SpeciesInfoView.swift
//  Petty App
//
//  Created by AlbertoOoXking on 15.01.25.
//

import SwiftUI

struct SpeciesInfoView: View {
    let species: String
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 120)
                            .shadow(radius: 8)

                        VStack {
                            Text(species)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Learn more about \(species)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 20) {
                            if let speciesInfo = viewModel.speciesList.first(where: { $0.species == species }) {
                                SectionCard(title: "Description", content: speciesInfo.description)

                                HStack(spacing: 15) {
                                    InfoCard(title: "Place of Found", content: speciesInfo.place_of_found, icon: "map")
                                    InfoCard(title: "Diet", content: speciesInfo.diet, icon: "fork.knife")
                                }

                                HStack(spacing: 15) {
                                    InfoCard(title: "Family", content: speciesInfo.family, icon: "tree")
                                    InfoCard(title: "Habitat", content: speciesInfo.habitat, icon: "leaf")
                                }
                            } else {
                                Text("Information not available for \(species).")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .padding()
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("About \(species)", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                    }
                }
            }
        }
    }
}
