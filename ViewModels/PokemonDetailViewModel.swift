//
//  PokemonDetailViewModel.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import Foundation
import Combine

class PokemonDetailViewModel: ObservableObject {
    @Published var pokemon: Pokemon?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isFavorite: Bool = false
    @Published var isAddingToFavorites: Bool = false
    
    private let pokemonService: PokemonServiceProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    let pokemonId: Int
    
    init(pokemonId: Int, 
         pokemonService: PokemonServiceProtocol = PokemonService.shared,
         favoritesRepository: FavoritesRepositoryProtocol = FavoritesRepository(),
         authService: AuthService = AuthService.shared) {
        self.pokemonId = pokemonId
        self.pokemonService = pokemonService
        self.favoritesRepository = favoritesRepository
        self.authService = authService
        
        loadPokemon()
        checkIfFavorite()
    }
    
    func loadPokemon() {
        isLoading = true
        errorMessage = nil
        
        print("Starting to fetch")
        pokemonService.fetchPokemon(id: pokemonId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] pokemon in
                    DispatchQueue.main.async {
                        self?.pokemon = pokemon
                        self?.checkIfFavorite()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleFavorite() {
        guard let pokemon = pokemon,
              let currentUser = authService.currentUser else {
            print("PokemonDetailViewModel: Cannot toggle favorite - missing pokemon or user")
            return
        }
        
        print("PokemonDetailViewModel: Toggling favorite for \(pokemon.name), current state: \(isFavorite)")
        isAddingToFavorites = true
        
        let operation = isFavorite ?
            favoritesRepository.removeFromFavorites(userId: currentUser.id, pokemonId: pokemon.id) :
            favoritesRepository.addToFavorites(userId: currentUser.id, pokemon: pokemon)
        
        operation
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isAddingToFavorites = false
                        if case .failure(let error) = completion {
                            print("PokemonDetailViewModel: Error toggling favorite: \(error)")
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] _ in
                    DispatchQueue.main.async {
                        let newState = !(self?.isFavorite ?? false)
                        print("PokemonDetailViewModel: Successfully toggled favorite, new state: \(newState)")
                        self?.isFavorite.toggle()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func checkIfFavorite() {
        guard let currentUser = authService.currentUser else {
            isFavorite = false
            return
        }
        
        favoritesRepository.isFavorite(userId: currentUser.id, pokemonId: pokemonId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] isFavorite in
                    DispatchQueue.main.async {
                        self?.isFavorite = isFavorite
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    var mainTypes: [PokemonType] {
        return pokemon?.types.prefix(2).map { $0 } ?? []
    }
    
    var mainAbilities: [PokemonAbility] {
        return pokemon?.abilities.prefix(3).map { $0 } ?? []
    }
    
    var mainMoves: [PokemonMove] {
        return pokemon?.moves.prefix(4).map { $0 } ?? []
    }
    
    var statMaxValue: Int {
        return pokemon?.stats.map { $0.baseStat }.max() ?? 100
    }
}
