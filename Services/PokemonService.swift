//
//  PokemonService.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import Foundation
import Combine

protocol PokemonServiceProtocol {
    func fetchPokemonList(offset: Int, limit: Int) -> AnyPublisher<PokemonResponse, Error>
    func fetchPokemon(id: Int) -> AnyPublisher<Pokemon, Error>
    func fetchPokemon(name: String) -> AnyPublisher<Pokemon, Error>
}

class PokemonService: PokemonServiceProtocol {
    static let shared = PokemonService()
    
    private let baseURL = "https://pokeapi.co/api/v2"
    private let session = URLSession.shared
    
    private init() {}
    
    func fetchPokemonList(offset: Int = 0, limit: Int = 20) -> AnyPublisher<PokemonResponse, Error> {
        guard let url = URL(string: "\(baseURL)/pokemon?offset=\(offset)&limit=\(limit)") else {
            return Fail(error: PokemonServiceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PokemonResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchPokemon(id: Int) -> AnyPublisher<Pokemon, Error> {
        guard let url = URL(string: "\(baseURL)/pokemon/\(id)") else {
            return Fail(error: PokemonServiceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Pokemon.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchPokemon(name: String) -> AnyPublisher<Pokemon, Error> {
        guard let url = URL(string: "\(baseURL)/pokemon/\(name.lowercased())") else {
            return Fail(error: PokemonServiceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Pokemon.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

enum PokemonServiceError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        }
    }
}
