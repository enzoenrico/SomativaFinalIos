//
//  PokemonListViewModel.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import Foundation
import Combine

class PokemonListViewModel: ObservableObject {
    @Published var pokemonList: [PokemonListItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasMoreData: Bool = true
    @Published var searchText: String = ""
    
    private let pokemonService: PokemonServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentOffset = 0
    private let pageSize = 20
    private var allPokemon: [PokemonListItem] = []
    
    init(pokemonService: PokemonServiceProtocol = PokemonService.shared) {
        self.pokemonService = pokemonService
        setupSearchBinding()
        loadPokemon()
    }
    
    private func setupSearchBinding() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.filterPokemon(with: searchText)
            }
            .store(in: &cancellables)
    }
    
    func loadPokemon() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        errorMessage = nil
        
        pokemonService.fetchPokemonList(offset: currentOffset, limit: pageSize)
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    DispatchQueue.main.async {
                        self?.handlePokemonResponse(response)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func handlePokemonResponse(_ response: PokemonResponse) {
        allPokemon.append(contentsOf: response.results)
        currentOffset = allPokemon.count
        hasMoreData = response.next != nil
        
        filterPokemon(with: searchText)
    }
    
    private func filterPokemon(with searchText: String) {
        if searchText.isEmpty {
            pokemonList = allPokemon
        } else {
            pokemonList = allPokemon.filter { pokemon in
                pokemon.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func loadMoreIfNeeded(pokemon: PokemonListItem) {
        guard let lastPokemon = pokemonList.last,
              lastPokemon.id == pokemon.id else {
            return
        }
        
        loadPokemon()
    }
    
    func refresh() {
        currentOffset = 0
        allPokemon.removeAll()
        pokemonList.removeAll()
        hasMoreData = true
        errorMessage = nil
        loadPokemon()
    }
}
