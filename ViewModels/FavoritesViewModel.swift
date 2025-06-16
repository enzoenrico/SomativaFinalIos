//
//  FavoritesViewModel.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoritePokemon] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(favoritesRepository: FavoritesRepositoryProtocol = FavoritesRepository(),
         authService: AuthService = AuthService.shared) {
        self.favoritesRepository = favoritesRepository
        self.authService = authService
        
        // Load favorites when user changes
        authService.$currentUser
            .sink { [weak self] user in
                if user != nil {
                    self?.loadFavorites()
                } else {
                    self?.favorites = []
                }
            }
            .store(in: &cancellables)
        
        // Listen for favorite changes notifications
        NotificationCenter.default.publisher(for: NSNotification.Name("FavoritesChanged"))
            .sink { [weak self] _ in
                print("FavoritesViewModel: Received FavoritesChanged notification, reloading...")
                self?.loadFavorites()
            }
            .store(in: &cancellables)
        
        // Load favorites immediately if user is already logged in
        if authService.currentUser != nil {
            loadFavorites()
        }
    }
    
    func loadFavorites() {
        guard let currentUser = authService.currentUser else {
            print("FavoritesViewModel: No current user, clearing favorites")
            favorites = []
            return
        }
        
        print("FavoritesViewModel: Loading favorites for user: \(currentUser.id)")
        isLoading = true
        errorMessage = nil
        
        favoritesRepository.getFavorites(for: currentUser.id)
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            print("FavoritesViewModel: Error loading favorites: \(error)")
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] favorites in
                    DispatchQueue.main.async {
                        print("FavoritesViewModel: Loaded \(favorites.count) favorites")
                        self?.favorites = favorites
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func removeFromFavorites(_ favorite: FavoritePokemon) {
        guard let currentUser = authService.currentUser else { return }
        
        favoritesRepository.removeFromFavorites(userId: currentUser.id, pokemonId: favorite.pokemonId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        DispatchQueue.main.async {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.favorites.removeAll { $0.id == favorite.id }
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func refresh() {
        loadFavorites()
    }
}
