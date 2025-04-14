//
//  PokemonData.swift
//  IOS201_PokemonSearch_35
//
//  Created by cmStudent on 2025/04/14.
//

import Foundation

struct Pokemon: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let imageURL: URL
    let japaneseName: String?

    init(id: Int, name: String, imageURL: URL, japaneseName: String? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.japaneseName = japaneseName
    }
}



@MainActor
class PokemonData: ObservableObject {
    @Published var pokemonList: [Pokemon] = []

    func fetchRandomPokemons(count: Int = 5) async {
        pokemonList = []

        for _ in 0..<count {
            let id = Int.random(in: 1...151)
            await fetchPokemon(id: id)
        }
    }

    private func fetchPokemon(id: Int) async {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PokemonAPIResponse.self, from: data)

            let imageUrl = URL(string: decoded.sprites.front_default ?? "") ?? URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")!

            // Fetch Japanese name
            let jpName = await fetchJapaneseName(id: id)

            let pokemon = Pokemon(
                id: decoded.id,
                name: decoded.name.capitalized,
                imageURL: imageUrl,
                japaneseName: jpName
            )

            pokemonList.append(pokemon)

        } catch {
            print("Error fetching Pokémon: \(error)")
        }
    }

    private func fetchJapaneseName(id: Int) async -> String? {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(id)") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let species = try JSONDecoder().decode(PokemonSpeciesResponse.self, from: data)

            if let jp = species.names.first(where: { $0.language.name == "ja" }) {
                return jp.name
            }

        } catch {
            print("Failed to fetch JP name: \(error)")
        }

        return nil
    }

    // MARK: - Decodable structs
    struct PokemonAPIResponse: Codable {
        let id: Int
        let name: String
        let sprites: Sprites

        struct Sprites: Codable {
            let front_default: String?
        }
    }

    struct PokemonSpeciesResponse: Codable {
        let names: [Name]

        struct Name: Codable {
            let name: String
            let language: Language

            struct Language: Codable {
                let name: String
            }
        }
    }
}
