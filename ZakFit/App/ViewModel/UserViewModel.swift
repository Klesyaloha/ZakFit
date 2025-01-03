//
//  LoginViewModel.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import Foundation
import Security
import SwiftUI

class UserViewModel: ObservableObject, @unchecked Sendable{
//    @Published var id: UUID?
//    @Published var nameUser: String = "" // Nom de l'utilisateur
//    @Published var surname: String = "" // Prénom de l'utilisateur
//    @Published var email: String = "alice.johnson@example.com" // Email
//    @Published var password: String = "hashed_password_3" // Mot de passe
//    @Published var sizeUser: Double = 0 // Taille (optionnel)
//    @Published var weight: Double = 0 // Poids (optionnel)
//    @Published var healthChoice: Int = 0 // Choix santé (optionnel)
//    @Published var eatChoice: [Int] = [] // Choix alimentaires (optionnel)
    @Published var currentUser = User(idUser: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, nameUser: "John", surname: "Doe", email: "alice.johnson@test.com",password: "hashed_password_3", sizeUser: 50, weight: 50, healthChoice: 0, eatChoice: [])
    @Published var originalUser: User?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    @Published var loginError: String? = nil // Message d'erreur éventuel
    @Published var registrationError: String? = nil // Erreur d'inscription
    @Published var isRegistered: Bool = false // Statut d'inscription
    
    @Published var showUpdateAlert: Bool = false  // Contrôler l'affichage de l'alerte
    @Published var alertUpdateMessage: String = "" // Message à afficher dans l'alerte
    
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
        
        guard let authData = ("\(currentUser.email):\(currentUser.password ?? "")").data(using: .utf8)?.base64EncodedString() else {
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
            
            // Décoder la réponse contenant le token et l'utilisateur
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            // Sauvegarder le token dans le Keychain
            guard KeychainManager.saveTokenToKeychain(loginResponse.token) else {
                DispatchQueue.main.async {
                    self.loginError = "Impossible de sauvegarder le token."
                }
                return
            }
            // Mettre à jour les données de l'utilisateur dans le ViewModel
            DispatchQueue.main.async {
                self.currentUser = loginResponse.user
                self.originalUser = self.currentUser.copy()
                self.isLoggedIn = true
                self.loginError = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.loginError = "Erreur: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchUserData(userID: UUID) async {
        guard let url = URL(string: "\(baseURL)\(userID.uuidString)") else {
            DispatchQueue.main.async {
                self.loginError = "URL invalide ou idUser manquant."
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let token = KeychainManager.getTokenFromKeychain() else {
            DispatchQueue.main.async {
                self.loginError = "Erreur lors de la récupération du token."
            }
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    DispatchQueue.main.async {
                        self.loginError = "Erreur HTTP : \(httpResponse.statusCode)"
                    }
                    // Debug : afficher la réponse brute en cas d'erreur
                    print("Réponse brute : \(String(data: data, encoding: .utf8) ?? "Non décodable")")
                    return
                }
            }

            // Debug : afficher les données brutes reçues
            print("Réponse brute : \(String(data: data, encoding: .utf8) ?? "Non décodable")")

            // Vérifier si la réponse contient une erreur explicite
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonDict = jsonObject as? [String: Any],
               jsonDict["error"] as? Bool == true {
                print("Erreur côté serveur : \(jsonDict["reason"] ?? "Raison inconnue")")
                return
            }

            // Décoder l'utilisateur
            let user = try JSONDecoder().decode(User.self, from: data)

            DispatchQueue.main.async {
                self.currentUser = user
                print("Utilisateur mis à jour : \(self.currentUser)")
            }
        } catch {
            DispatchQueue.main.async {
                self.loginError = "Erreur : \(error.localizedDescription)"
            }
        }
    }

    
    func register() async {
        guard let url = URL(string: "\(baseURL)register") else {
            DispatchQueue.main.async {
                self.registrationError = "URL invalide."
            }
            return
        }
        
        // Préparer les données à envoyer
        let userData = UserRegistrationRequest(
            nameUser: self.currentUser.nameUser,
            surname: self.currentUser.surname,
            email: self.currentUser.email,
            password: self.currentUser.password!,
            sizeUser: self.currentUser.sizeUser,
            weight: self.currentUser.weight,
            healthChoice: self.currentUser.healthChoice,
            eatChoice: self.currentUser.eatChoice
        )
        
        do {
            let jsonData = try JSONEncoder().encode(userData)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let (_, response) = try await URLSession.shared.data(for: request)
            
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
        print(isLoggedIn)
        KeychainManager.deleteTokenFromKeychain()
        print("Déconnecté. Token supprimé.")
        clearData()
        print("Données locales supprimées.")
        isLoggedIn = false
        print(isLoggedIn)
    }
    
    // Fonction pour mettre à jour l'utilisateur
    func updateUserData() async {
        // Initialiser la variable qui stockera les champs modifiés
        var updatedFields = PartialUserUpdate()
        
        // Comparer chaque champ et ajouter uniquement ceux qui ont changé
        if currentUser.nameUser != originalUser?.nameUser {
            updatedFields.nameUser = currentUser.nameUser
        }
        if currentUser.surname != originalUser?.surname {
            updatedFields.surname = currentUser.surname
        }
        if currentUser.email != originalUser?.email {
            updatedFields.email = currentUser.email
        }
        if currentUser.sizeUser != originalUser?.sizeUser {
            updatedFields.sizeUser = currentUser.sizeUser
        }
        if currentUser.weight != originalUser?.weight {
            updatedFields.weight = currentUser.weight
        }
        if currentUser.healthChoice != originalUser?.healthChoice {
            updatedFields.healthChoice = currentUser.healthChoice
        }
        if currentUser.eatChoice != originalUser?.eatChoice {
            updatedFields.eatChoice = currentUser.eatChoice
        }
        // Vérification de la connexion avant de commencer la requête
        guard let url = URL(string: "\(baseURL)\(currentUser.idUser.uuidString)") else {
            errorMessage = "URL invalide"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Récupérer le token depuis le Keychain
        guard let token = KeychainManager.getTokenFromKeychain() else {
            DispatchQueue.main.async {
                self.errorMessage = "Erreur lors de la récupération du token."
            }
            return
        }
        
        // Ajouter le token à l'en-tête Authorization
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Créer un encodeur pour encoder l'objet currentUser
        let encoder = JSONEncoder()
        do {
            let body = try encoder.encode(updatedFields)
            request.httpBody = body
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Erreur d'encodage des données."
            }
            return
        }
        
        // Démarrer l'appel réseau sur un thread d'arrière-plan
        DispatchQueue.main.async {
            self.isLoading = true  // Mise à jour de isLoading sur le thread principal
        }
        do {
            // Effectuer la requête HTTP asynchrone
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Vérifier le statut HTTP de la réponse
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Si le statut est 200, décoder l'utilisateur mis à jour
                let decoder = JSONDecoder()
                if let updatedUser = try? decoder.decode(User.self, from: data) {
                    // Mettre à jour currentUser avec l'utilisateur mis à jour
                    DispatchQueue.main.async {
                        self.currentUser = updatedUser
                        self.originalUser = self.currentUser.copy()
                        self.errorMessage = nil
                        self.alertUpdateMessage = "Vos informations ont été mises à jour avec succès."
                        
                        // Générer un message d'alerte indiquant quels champs ont été modifiés
                        var modifiedFields = [String]()
                        if let _ = updatedFields.nameUser { modifiedFields.append("Nom") }
                        if let _ = updatedFields.surname { modifiedFields.append("Prénom") }
                        if let _ = updatedFields.email { modifiedFields.append("Email") }
                        if let _ = updatedFields.sizeUser { modifiedFields.append("Taille") }
                        if let _ = updatedFields.weight { modifiedFields.append("Poids") }
                        if let _ = updatedFields.healthChoice { modifiedFields.append("Choix de santé") }
                        if let _ = updatedFields.eatChoice { modifiedFields.append("Choix alimentaires") }
                        
                        self.alertUpdateMessage = "Champs modifiés : " + modifiedFields.joined(separator: ", ")
                        print(self.showUpdateAlert)
                        self.objectWillChange.send()
                        self.showUpdateAlert = true // Afficher l'alerte
                        print(self.showUpdateAlert)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Impossible de décoder la réponse."
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur de la requête, statut \(response)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Erreur de connexion: \(error.localizedDescription)"
            }
        }
        
        // Terminer le chargement sur le thread principal
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    // Réinitialiser les données utilisateur en cas de déconnexion
    func clearData() {
        self.currentUser = User()
        self.originalUser = User()
    }
    
    // Fonction pour modifer le poids et la taille du currentUser par 0.1
    func changeUserProperty(_ key: String, _ operation: String) {
    objectWillChange.send()
    switch key {
        case "sizeUser":
            if operation == "+" {
                currentUser.sizeUser += 0.1
            } else if operation == "-" {
                currentUser.sizeUser = max(0, currentUser.sizeUser - 0.1) // Empêcher les tailles négatives
            }
        case "weight":
            if operation == "+" {
                currentUser.weight += 0.1
            } else if operation == "-" {
                currentUser.weight = max(0, currentUser.weight - 0.1) // Empêcher les poids négatifs
            }
        case "healthChoice":
            currentUser.healthChoice = Int(operation) ?? 0
        default:
            break
        }
    }
    
    // Fonction pour modifier la selection EatChoice du currentUser
    func updateEatChoice(index: Int) {
        objectWillChange.send()
        if currentUser.eatChoice.contains(index) {
            // Si l'index est déjà sélectionné, on le supprime
            self.currentUser.eatChoice.removeAll { $0 == index }
        } else {
            // Sinon, on l'ajoute
            self.currentUser.eatChoice.append(index)
        }
    }
}

extension User {
    func copy() -> User {
        return User(idUser: self.idUser,
                    nameUser: self.nameUser,
                    surname: self.surname,
                    email: self.email,
                    sizeUser: self.sizeUser,
                    weight: self.weight,
                    healthChoice: self.healthChoice,
                    eatChoice: self.eatChoice)
    }
}
