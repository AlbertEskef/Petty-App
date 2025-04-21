//
//  SpeciesRepository.swift
//  Petty App
//
//  Created by AlbertoOoXking on 15.01.25.
//

import Foundation

class SpeciesRepository {
    private let apiURL = "https://www.freetestapi.com/api/v1/animals"

    func fetchSpecies() async throws -> [Species] {
        guard let url = URL(string: apiURL) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let speciesList = try JSONDecoder().decode([Species].self, from: data)

        return speciesList
    }
}
