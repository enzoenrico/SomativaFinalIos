//
//  AuthViewModel.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    
    // Login properties
    @Published var loginEmail: String = ""
    @Published var loginPassword: String = ""
    
    // Register properties
    @Published var registerUsername: String = ""
    @Published var registerEmail: String = ""
    @Published var registerPassword: String = ""
    @Published var registerConfirmPassword: String = ""
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthService = AuthService.shared) {
        self.authService = authService
        
        // Bind to auth service
        authService.$currentUser
            .assign(to: \.currentUser, on: self)
            .store(in: &cancellables)
        
        authService.$isLoggedIn
            .assign(to: \.isLoggedIn, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Login
    func login() {
        guard isValidLogin else {
            errorMessage = "Email e senha são obrigatórios"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        authService.login(email: loginEmail, password: loginPassword)
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] user in
                    DispatchQueue.main.async {
                        self?.clearLoginFields()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Register
    func register() {
        guard isValidRegistration else {
            errorMessage = getRegistrationErrorMessage()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        authService.register(
            username: registerUsername,
            email: registerEmail,
            password: registerPassword
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            },
            receiveValue: { [weak self] user in
                DispatchQueue.main.async {
                    self?.clearRegisterFields()
                }
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Logout
    func logout() {
        authService.logout()
        clearAllFields()
    }
    
    // MARK: - Validation
    var isValidLogin: Bool {
        return !loginEmail.isEmpty && !loginPassword.isEmpty
    }
    
    var isValidRegistration: Bool {
        return !registerUsername.isEmpty &&
               !registerEmail.isEmpty &&
               !registerPassword.isEmpty &&
               registerPassword == registerConfirmPassword &&
               isValidEmail(registerEmail) &&
               isValidPassword(registerPassword)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    private func getRegistrationErrorMessage() -> String {
        if registerUsername.isEmpty {
            return "Nome de usuário é obrigatório"
        }
        if registerEmail.isEmpty {
            return "Email é obrigatório"
        }
        if !isValidEmail(registerEmail) {
            return "Email inválido"
        }
        if registerPassword.isEmpty {
            return "Senha é obrigatória"
        }
        if !isValidPassword(registerPassword) {
            return "Senha deve ter pelo menos 6 caracteres"
        }
        if registerPassword != registerConfirmPassword {
            return "Senhas não coincidem"
        }
        return "Dados inválidos"
    }
    
    // MARK: - Helper Methods
    private func clearLoginFields() {
        loginEmail = ""
        loginPassword = ""
    }
    
    private func clearRegisterFields() {
        registerUsername = ""
        registerEmail = ""
        registerPassword = ""
        registerConfirmPassword = ""
    }
    
    private func clearAllFields() {
        clearLoginFields()
        clearRegisterFields()
        errorMessage = nil
    }
}
