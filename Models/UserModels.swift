//
//  UserModels.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import Foundation
import CoreData

// MARK: - User Model for Auth
struct User: Codable, Identifiable {
    let id: UUID
    let username: String
    let email: String
    let createdAt: Date
    
    init(id: UUID = UUID(), username: String, email: String, createdAt: Date = Date()) {
        self.id = id
        self.username = username
        self.email = email
        self.createdAt = createdAt
    }
}

// MARK: - User Registration Model
struct UserRegistration {
    let username: String
    let email: String
    let password: String
    let confirmPassword: String
    
    var isValid: Bool {
        return !username.isEmpty &&
               !email.isEmpty &&
               !password.isEmpty &&
               password == confirmPassword &&
               isValidEmail(email) &&
               isValidPassword(password)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
}

// MARK: - User Login Model
struct UserLogin {
    let email: String
    let password: String
    
    var isValid: Bool {
        return !email.isEmpty && !password.isEmpty
    }
}

// MARK: - Favorite Pokemon Model
struct FavoritePokemon: Identifiable {
    let id: UUID
    let userId: UUID
    let pokemonId: Int
    let pokemonName: String
    let pokemonImageUrl: String?
    let addedAt: Date
    
    init(id: UUID = UUID(), userId: UUID, pokemonId: Int, pokemonName: String, pokemonImageUrl: String? = nil, addedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.pokemonId = pokemonId
        self.pokemonName = pokemonName
        self.pokemonImageUrl = pokemonImageUrl
        self.addedAt = addedAt
    }
}
