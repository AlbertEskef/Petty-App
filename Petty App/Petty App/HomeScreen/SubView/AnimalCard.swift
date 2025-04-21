//
//  AnimalCard.swift
//  Petty App
//
//  Created by AlbertoOoXking on 11.01.25.
//

import SwiftUI

struct AnimalCard: View {
    let animal: Animal
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: animal.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 115, height: 115)
            } placeholder: {
                ProgressView()
                    .frame(width: 115, height: 115)
            }
            Text(animal.name)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}
