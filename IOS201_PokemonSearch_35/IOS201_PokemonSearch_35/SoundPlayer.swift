//
//  SoundPlayer.swift
//  IOS201_PokemonSearch_35
//
//  Created by cmStudent on 2025/04/14.
//

import AVFoundation

class SoundPlayer {
    static var player: AVAudioPlayer?

    static func playCry(for pokemonName: String) {
        let name = pokemonName.lowercased()
        guard let url = URL(string: "https://play.pokemonshowdown.com/audio/cries/\(name).mp3") else { return }

        // Download and play
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        player = try AVAudioPlayer(data: data)
                        player?.prepareToPlay()
                        player?.play()
                    } catch {
                        print("❌ Failed to play cry: \(error)")
                    }
                }
            } else {
                print("❌ Could not load cry: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        task.resume()
    }
}
