//
//  FavoritesRepository.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import Foundation
import CoreData
import Combine

protocol FavoritesRepositoryProtocol {
    func getFavorites(for userId: UUID) -> AnyPublisher<[FavoritePokemon], Error>
    func addToFavorites(userId: UUID, pokemon: Pokemon) -> AnyPublisher<Void, Error>
    func removeFromFavorites(userId: UUID, pokemonId: Int) -> AnyPublisher<Void, Error>
    func isFavorite(userId: UUID, pokemonId: Int) -> AnyPublisher<Bool, Error>
}

class FavoritesRepository: FavoritesRepositoryProtocol {
    private let coreDataStack = CoreDataStack.shared
    
    func getFavorites(for userId: UUID) -> AnyPublisher<[FavoritePokemon], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(FavoritesError.unknown))
                return
            }
            
            print("FavoritesRepository: Fetching favorites for user: \(userId)")
            
            let fetchRequest: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user.id == %@", userId as CVarArg)
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteEntity.addedAt, ascending: false)]
            
            do {
                let favoriteEntities = try self.coreDataStack.context.fetch(fetchRequest)
                print("FavoritesRepository: Found \(favoriteEntities.count) favorite entities")
                
                let favorites = favoriteEntities.compactMap { entity -> FavoritePokemon? in
                    guard let id = entity.id,
                          let pokemonName = entity.pokemonName,
                          let addedAt = entity.addedAt else {
                        print("FavoritesRepository: Skipping invalid entity")
                        return nil
                    }
                    
                    print("FavoritesRepository: Converting entity for Pokemon: \(pokemonName)")
                    return FavoritePokemon(
                        id: id,
                        userId: userId,
                        pokemonId: Int(entity.pokemonId),
                        pokemonName: pokemonName,
                        pokemonImageUrl: entity.pokemonImageUrl,
                        addedAt: addedAt
                    )
                }
                
                print("FavoritesRepository: Returning \(favorites.count) favorites")
                promise(.success(favorites))
            } catch {
                print("FavoritesRepository: Error fetching favorites: \(error)")
                promise(.failure(FavoritesError.fetchFailed))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addToFavorites(userId: UUID, pokemon: Pokemon) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(FavoritesError.unknown))
                return
            }
            
            print("FavoritesRepository: Adding Pokemon \(pokemon.name) (ID: \(pokemon.id)) to favorites for user: \(userId)")
            
            // Check if already in favorites
            let fetchRequest: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user.id == %@ AND pokemonId == %d", userId as CVarArg, pokemon.id)
            
            do {
                let existingFavorites = try self.coreDataStack.context.fetch(fetchRequest)
                if !existingFavorites.isEmpty {
                    print("FavoritesRepository: Pokemon already in favorites")
                    promise(.failure(FavoritesError.alreadyExists))
                    return
                }
                
                // Get user entity
                let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
                userFetchRequest.predicate = NSPredicate(format: "id == %@", userId as CVarArg)
                
                guard let userEntity = try self.coreDataStack.context.fetch(userFetchRequest).first else {
                    print("FavoritesRepository: User entity not found")
                    promise(.failure(FavoritesError.userNotFound))
                    return
                }
                
                // Create favorite entity
                let favoriteEntity = FavoriteEntity(context: self.coreDataStack.context)
                favoriteEntity.id = UUID()
                favoriteEntity.pokemonId = Int32(pokemon.id)
                favoriteEntity.pokemonName = pokemon.name
                favoriteEntity.pokemonImageUrl = pokemon.sprites.mainImageUrl
                favoriteEntity.addedAt = Date()
                favoriteEntity.user = userEntity
                
                try self.coreDataStack.context.save()
                print("FavoritesRepository: Successfully added Pokemon to favorites")
                
                // Post notification that favorites changed
                NotificationCenter.default.post(name: NSNotification.Name("FavoritesChanged"), object: nil)
                
                promise(.success(()))
                
            } catch {
                print("FavoritesRepository: Error adding to favorites: \(error)")
                promise(.failure(FavoritesError.addFailed))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeFromFavorites(userId: UUID, pokemonId: Int) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(FavoritesError.unknown))
                return
            }
            
            let fetchRequest: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user.id == %@ AND pokemonId == %d", userId as CVarArg, pokemonId)
            
            do {
                let favoriteEntities = try self.coreDataStack.context.fetch(fetchRequest)
                
                guard let favoriteEntity = favoriteEntities.first else {
                    promise(.failure(FavoritesError.notFound))
                    return
                }
                
                self.coreDataStack.context.delete(favoriteEntity)
                try self.coreDataStack.context.save()
                
                // Post notification that favorites changed
                NotificationCenter.default.post(name: NSNotification.Name("FavoritesChanged"), object: nil)
                
                promise(.success(()))
                
            } catch {
                promise(.failure(FavoritesError.removeFailed))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func isFavorite(userId: UUID, pokemonId: Int) -> AnyPublisher<Bool, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(FavoritesError.unknown))
                return
            }
            
            let fetchRequest: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user.id == %@ AND pokemonId == %d", userId as CVarArg, pokemonId)
            
            do {
                let count = try self.coreDataStack.context.count(for: fetchRequest)
                promise(.success(count > 0))
            } catch {
                promise(.failure(FavoritesError.checkFailed))
            }
        }
        .eraseToAnyPublisher()
    }
}

enum FavoritesError: Error, LocalizedError {
    case alreadyExists
    case notFound
    case userNotFound
    case fetchFailed
    case addFailed
    case removeFailed
    case checkFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .alreadyExists:
            return "Pokémon já está nos favoritos"
        case .notFound:
            return "Pokémon não encontrado nos favoritos"
        case .userNotFound:
            return "Usuário não encontrado"
        case .fetchFailed:
            return "Falha ao buscar favoritos"
        case .addFailed:
            return "Falha ao adicionar aos favoritos"
        case .removeFailed:
            return "Falha ao remover dos favoritos"
        case .checkFailed:
            return "Falha ao verificar favoritos"
        case .unknown:
            return "Erro desconhecido"
        }
    }
}
