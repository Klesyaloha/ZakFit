//
//  LoginViewModel.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import Foundation
import Security

class UserViewModel: ObservableObject, @unchecked Sendable{
    @Published var id: UUID?
    @Published var nameUser: String = "" // Nom de l'utilisateur
    @Published var surname: String = "" // Prénom de l'utilisateur
    @Published var email: String = "alice.johnson@example.com" // Email
    @Published var password: String = "hashed_password_3" // Mot de passe
    @Published var size: Double? = nil // Taille (optionnel)
    @Published var weight: Double? = nil // Poids (optionnel)
    @Published var healthChoice: Int? = nil // Choix santé (optionnel)
    @Published var eatChoice: [Int]? = nil // Choix alimentaires (optionnel)
    @Published var token: String = ""
    
    @Published var isLoggedIn: Bool = false
    @Published var loginError: String? = nil // Message d'erreur éventuel
    @Published var registrationError: String? = nil // Erreur d'inscription
    @Published var isRegistered: Bool = false // Statut d'inscription
    
    private let baseURL = "http://127.0.0.1:8080/users/"
    
    
    func login() async {
        guard let url = URL(string: "\(baseURL)login") else {
            DispatchQueue.main.async {
                self.loginError = "URL invalide."
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let authData = ("\(email):\(password)").data(using: .utf8)?.base64EncodedString() else {
            DispatchQueue.main.async {
                self.loginError = "Erreur lors du codage des identifiants."
            }
            return
        }
        request.addValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.loginError = "Identifiants incorrects ou erreur serveur."
                }
                return
            }
            
            print("Réponse brute de l'API: \(String(data: data, encoding: .utf8) ?? "Erreur d'encodage des données")")
            
            // Décoder la réponse contenant le token et l'utilisateur
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            let rawResponse = String(data: data, encoding: .utf8)
            
            print("Bonjour \(loginResponse.user.nameUser)")
            // Sauvegarder le token dans le Keychain
            guard KeychainManager.saveTokenToKeychain(loginResponse.token) else {
                DispatchQueue.main.async {
                    self.loginError = "Impossible de sauvegarder le token."
                }
                return
            }
            
            // Mettre à jour les données de l'utilisateur dans le ViewModel
            DispatchQueue.main.async {
                self.token = loginResponse.token
                self.id = UUID(uuidString: loginResponse.user.idUser ?? "")
                self.nameUser = loginResponse.user.nameUser
                self.surname = loginResponse.user.surname
                self.email = loginResponse.user.email
                self.email = loginResponse.user.email
                self.size = loginResponse.user.size
                self.weight = loginResponse.user.weight
                self.healthChoice = loginResponse.user.healthChoice
                self.eatChoice = loginResponse.user.eatChoice
                self.isLoggedIn = true
                self.loginError = nil
                print("do \(self.nameUser)")
            }
            print("do2 \(self.nameUser)")
        } catch {
            DispatchQueue.main.async {
                self.loginError = "Erreur: \(error.localizedDescription)"
            }
        }
        print("do4 \(self.nameUser)")
    }
    
    func register() async {
        guard let url = URL(string: "\(baseURL)/register") else {
            DispatchQueue.main.async {
                self.registrationError = "URL invalide."
            }
            return
        }
        
        // Préparer les données à envoyer
        let userData = UserRegistrationRequest(
            nameUser: nameUser,
            surname: surname,
            email: email,
            password: password,
            size: size,
            weight: weight,
            healthChoice: healthChoice,
            eatChoice: eatChoice
        )
        
        do {
            let jsonData = try JSONEncoder().encode(userData)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                DispatchQueue.main.async {
                    self.registrationError = "Échec de l'inscription."
                }
                return
            }
            
            DispatchQueue.main.async {
                self.isRegistered = true
                self.registrationError = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.registrationError = "Erreur: \(error.localizedDescription)"
            }
        }
    }
    
    func logout() {
        KeychainManager.deleteTokenFromKeychain()
        print("Déconnecté. Token supprimé.")
    }
    
    private func updateUserData(with user: User) {
        self.id = UUID(uuidString: user.idUser ?? "")
        self.nameUser = user.nameUser
        self.surname = user.surname
        self.email = user.email
        self.weight = user.weight
        self.healthChoice = user.healthChoice
        self.eatChoice = user.eatChoice
    }
    
    // Réinitialiser les données utilisateur en cas de déconnexion
    func clearData() {
        self.id = nil
        self.nameUser = ""
        self.surname = ""
        self.email = ""
        self.weight = 0.0
        self.healthChoice = 0
        self.eatChoice = []
        self.token = ""
    }
}
