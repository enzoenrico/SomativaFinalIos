//
//  AuthService.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import Foundation
import CoreData
import CryptoKit
import Combine

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    var isLoggedIn: Bool { get }
    func register(username: String, email: String, password: String) -> AnyPublisher<User, Error>
    func login(email: String, password: String) -> AnyPublisher<User, Error>
    func logout()
}

class AuthService: ObservableObject, AuthServiceProtocol {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    private let coreDataStack = CoreDataStack.shared
    private let userDefaults = UserDefaults.standard
    private let currentUserKey = "currentUser"
    
    private init() {
        loadCurrentUser()
    }
    
    func register(username: String, email: String, password: String) -> AnyPublisher<User, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(AuthError.unknown))
                return
            }
            
            // Check if user already exists
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)
            
            do {
                let existingUsers = try self.coreDataStack.context.fetch(fetchRequest)
                if !existingUsers.isEmpty {
                    promise(.failure(AuthError.userAlreadyExists))
                    return
                }
                
                // Create new user
                let userEntity = UserEntity(context: self.coreDataStack.context)

                userEntity.id = UUID()
                userEntity.username = username
                userEntity.email = email
                userEntity.passwordHash = self.hashPassword(password)
                userEntity.createdAt = Date()
                
                try self.coreDataStack.context.save()
                
                let user = User(
                    id: userEntity.id!,
                    username: username,
                    email: email,
                    createdAt: userEntity.createdAt!
                )
                
                self.setCurrentUser(user)
                promise(.success(user))
                
            } catch {
                promise(.failure(AuthError.registrationFailed))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(AuthError.unknown))
                return
            }
            
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)
            
            do {
                let users = try self.coreDataStack.context.fetch(fetchRequest)
                
                guard let userEntity = users.first,
                      let storedPasswordHash = userEntity.passwordHash,
                      self.verifyPassword(password, hash: storedPasswordHash) else {
                    promise(.failure(AuthError.invalidCredentials))
                    return
                }
                
                let user = User(
                    id: userEntity.id!,
                    username: userEntity.username!,
                    email: userEntity.email!,
                    createdAt: userEntity.createdAt!
                )
                
                self.setCurrentUser(user)
                promise(.success(user))
                
            } catch {
                promise(.failure(AuthError.loginFailed))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        userDefaults.removeObject(forKey: currentUserKey)
    }
    
    private func setCurrentUser(_ user: User) {
        currentUser = user
        isLoggedIn = true
        
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: currentUserKey)
        }
    }
    
    private func loadCurrentUser() {
        guard let userData = userDefaults.data(forKey: currentUserKey),
              let user = try? JSONDecoder().decode(User.self, from: userData) else {
            return
        }
        
        currentUser = user
        isLoggedIn = true
    }
    
    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func verifyPassword(_ password: String, hash: String) -> Bool {
        return hashPassword(password) == hash
    }
}

enum AuthError: Error, LocalizedError {
    case userAlreadyExists
    case invalidCredentials
    case registrationFailed
    case loginFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .userAlreadyExists:
            return "Usuário já existe com este email"
        case .invalidCredentials:
            return "Email ou senha inválidos"
        case .registrationFailed:
            return "Falha no cadastro"
        case .loginFailed:
            return "Falha no login"
        case .unknown:
            return "Erro desconhecido"
        }
    }
}
