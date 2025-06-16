//
//  PokemonModels.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import Foundation

// MARK: - Pokemon Response
struct PokemonResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
}

// MARK: - Pokemon List Item
struct PokemonListItem: Codable, Identifiable {
    let id = UUID()
    let name: String
    let url: String
    
    var pokemonId: Int {
        guard let id = url.split(separator: "/").last, let pokemonId = Int(id) else {
            return 0
        }
        return pokemonId
    }
    
    enum CodingKeys: String, CodingKey {
        case name, url
    }
}

// MARK: - Pokemon Detail
struct Pokemon: Codable, Identifiable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let baseExperience: Int?
    let abilities: [PokemonAbility]
    let moves: [PokemonMove]
    let sprites: PokemonSprites
    let stats: [PokemonStat]
    let types: [PokemonType]
    
    var heightInMeters: Double {
        return Double(height) / 10.0
    }
    
    var weightInKilograms: Double {
        return Double(weight) / 10.0
    }
    
    var formattedName: String {
        return name.capitalized
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, height, weight, abilities, moves, sprites, stats, types
        case baseExperience = "base_experience"
    }
}

// MARK: - Pokemon Ability
struct PokemonAbility: Codable, Identifiable {
    let id = UUID()
    let ability: Ability
    let isHidden: Bool
    let slot: Int
    
    enum CodingKeys: String, CodingKey {
        case ability, slot
        case isHidden = "is_hidden"
    }
}

struct Ability: Codable {
    let name: String
    let url: String
    
    var formattedName: String {
        return name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

// MARK: - Pokemon Move
struct PokemonMove: Codable, Identifiable {
    let id = UUID()
    let move: Move
    
    enum CodingKeys: String, CodingKey {
        case move
    }
}

struct Move: Codable {
    let name: String
    let url: String
    
    var formattedName: String {
        return name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

// MARK: - Pokemon Sprites
struct PokemonSprites: Codable {
    let backDefault: String?
    let backShiny: String?
    let frontDefault: String?
    let frontShiny: String?
    let other: OtherSprites?
    
    var mainImageUrl: String? {
        return other?.officialArtwork?.frontDefault ?? frontDefault
    }
    
    enum CodingKeys: String, CodingKey {
        case other
        case backDefault = "back_default"
        case backShiny = "back_shiny"
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
    }
}

struct OtherSprites: Codable {
    let officialArtwork: OfficialArtwork?
    
    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Codable {
    let frontDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

// MARK: - Pokemon Stat
struct PokemonStat: Codable, Identifiable {
    let id = UUID()
    let baseStat: Int
    let effort: Int
    let stat: Stat
    
    enum CodingKeys: String, CodingKey {
        case effort, stat
        case baseStat = "base_stat"
    }
}

struct Stat: Codable {
    let name: String
    let url: String
    
    var formattedName: String {
        switch name {
        case "hp": return "HP"
        case "attack": return "Attack"
        case "defense": return "Defense"
        case "special-attack": return "Sp. Attack"
        case "special-defense": return "Sp. Defense"
        case "speed": return "Speed"
        default: return name.capitalized
        }
    }
}

// MARK: - Pokemon Type
struct PokemonType: Codable, Identifiable {
    let id = UUID()
    let slot: Int
    let type: TypeInfo
    
    enum CodingKeys: String, CodingKey {
        case slot, type
    }
}

struct TypeInfo: Codable {
    let name: String
    let url: String
    
    var formattedName: String {
        return name.capitalized
    }
}
