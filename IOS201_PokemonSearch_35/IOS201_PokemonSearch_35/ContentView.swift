//
//  ContentView.swift
//  IOS201_PokemonSearch_35
//
//  Created by cmStudent on 2025/04/14.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var pokemonData = PokemonData()
    @State private var selectedPokemon: Pokemon?
    @State private var showPreview = false

    var body: some View {
        NavigationView {
            VStack {
                Button("ポケモンをひく！") {
                    Task {
                        await pokemonData.fetchRandomPokemons()
                    }
                }
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .clipShape(Capsule())

                List(pokemonData.pokemonList) { pokemon in
                    HStack(spacing: 10) {
                        AsyncImage(url: pokemon.imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture {
                                        selectedPokemon = pokemon
                                        showPreview = true
                                    }
                            default:
                                ProgressView()
                            }
                        }

                        VStack(alignment: .leading) {
                            Text(pokemon.japaneseName ?? pokemon.name)
                                .font(.headline)

                            Text("英語名: \(pokemon.name)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button {
                            SoundPlayer.playCry(for: pokemon.name)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(.plain)
            }
            .navigationTitle("ミニポケ図鑑")
            .sheet(isPresented: $showPreview) {
                if let pokemon = selectedPokemon {
                    VStack(spacing: 10) {
                        Text(pokemon.japaneseName ?? pokemon.name)
                            .font(.largeTitle)
                            .bold()

                        AsyncImage(url: pokemon.imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 200)
                            default:
                                ProgressView()
                            }
                        }

                        Text("ポケモンID: \(pokemon.id)")
                            .font(.title3)
                            .padding(.top)

                        Button("🔊 鳴き声をきく") {
                            SoundPlayer.playCry(for: pokemon.name)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)

                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
