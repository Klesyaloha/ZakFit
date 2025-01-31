//
//  MealViewModel.swift
//  ZakFit
//
//  Created by Klesya on 06/01/2025.
//

import Foundation
import Combine
import SwiftUICore

class MealViewModel: ObservableObject {
    // Liste des repas associés à l'utilisateur
    @Published var meals: [MealWithFoods] = []
    @Published var mealsOnly: [Meal] = []
    @Published var selectedMeal: MealWithFoods?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @ObservedObject var compositionViewModel = CompositionViewModel() // Ajouter CompositionViewModel pour gérer les compositions
    
    private let baseURL = "http://192.168.0.199:8080/meals/"
    
    // Charger tous les repas de l'utilisateur
    func fetchMeals() async {
        guard let token = KeychainManager.getTokenFromKeychain() else {
            self.errorMessage = "Token manquant. Veuillez vous reconnecter."
            return
        }
        
        guard let url = URL(string: "\(baseURL)") else {
            self.errorMessage = "URL invalide."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        self.isLoading = true
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // Décode les dates au format ISO8601
            
            do {
                let decodedMeals = try decoder.decode([Meal].self, from: data)
                self.mealsOnly = decodedMeals
//                print(decodedMeals)
            } catch {
                self.errorMessage = "Erreur lors du décodage des repas: \(error.localizedDescription)"
            }
        } catch {
            self.errorMessage = "Erreur lors du chargement des repas: \(error.localizedDescription)"
        }
        self.isLoading = false
    }
    
    // Ajouter un repas
    func addMeal(_ meal: Meal) async {
        guard let token = KeychainManager.getTokenFromKeychain() else {
            self.errorMessage = "Token manquant. Veuillez vous reconnecter."
            return
        }
        
        guard let url = URL(string: baseURL) else {
            self.errorMessage = "URL invalide."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let isoFormatter = ISO8601DateFormatter()
        let jsonBody: [String: Any] = [
            "nameMeal": meal.nameMeal,
            "typeOfMeal": meal.typeOfMeal,
            "quantityMeal": meal.quantityMeal,
            "dateMeal": isoFormatter.string(from: meal.dateMeal), // Format ISO 8601
            "caloriesByMeal": meal.caloriesByMeal
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonBody)
            request.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                throw URLError(.badServerResponse)
            }
            await fetchMeals() // Recharge la liste des repas après ajout
        } catch {
            self.errorMessage = "Erreur lors de l'ajout du repas: \(error.localizedDescription)"
        }
    }
    
    // Mettre à jour un repas existant
    func updateMeal(_ meal: Meal) async {
        guard let token = KeychainManager.getTokenFromKeychain() else {
            self.errorMessage = "Token manquant. Veuillez vous reconnecter."
            return
        }
        
        guard let url = URL(string: "\(baseURL)\(meal.id.uuidString)") else {
            self.errorMessage = "URL ou ID invalide."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let isoFormatter = ISO8601DateFormatter()
        let jsonBody: [String: Any] = [
            "nameMeal": meal.nameMeal,
            "typeOfMeal": meal.typeOfMeal,
            "quantityMeal": meal.quantityMeal,
            "dateMeal": isoFormatter.string(from: meal.dateMeal), // Format ISO 8601
            "caloriesByMeal": meal.caloriesByMeal
//            ,
//            "user": {
//                "id": meal.user.id
//            }
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonBody)
            request.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                throw URLError(.badServerResponse)
            }
            
            await fetchMeals() // Recharge la liste des repas après mise à jour
        } catch {
            self.errorMessage = "Erreur lors de la mise à jour du repas: \(error.localizedDescription)"
        }
    }
    
    // Supprimer un repas
    func deleteMeal(_ mealID: UUID) async {
        guard let token = KeychainManager.getTokenFromKeychain() else {
            self.errorMessage = "Token manquant. Veuillez vous reconnecter."
            return
        }
        
        guard let url = URL(string: "\(baseURL)\(mealID.uuidString)") else {
            self.errorMessage = "URL ou ID invalide."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                throw URLError(.badServerResponse)
            }
            
            self.mealsOnly.removeAll { $0.id == mealID }
        } catch {
            self.errorMessage = "Erreur lors de la suppression du repas: \(error.localizedDescription)"
        }
    }
    
    // Récupérer tous les repas d'un utilisateur avec leurs aliments associés
    func fetchMealsWithFood() async {
        // Vérification du token
        guard let token = KeychainManager.getTokenFromKeychain() else {
            self.errorMessage = "Token manquant. Veuillez vous reconnecter."
            return
        }
        
        // Vérification de l'URL
        guard let url = URL(string: "\(baseURL)all_meals") else {
            self.errorMessage = "URL invalide."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Indiquer que l'on charge les données
        self.isLoading = true
        
        do {
            // Tentative de récupération des données via le réseau
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Vérification du code de statut HTTP
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            // Décodage des données en MealWithFoods
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // Décode les dates au format ISO8601
            
            // Tentative de décodage des données
            do {
                let decodedMealsWithFood = try decoder.decode([MealWithFoods].self, from: data)
                self.meals = decodedMealsWithFood
//                print(decodedMealsWithFood)
            } catch let decodingError as DecodingError {
                // Gestion des erreurs de décryptage spécifiques
                switch decodingError {
                case .typeMismatch(let type, let context):
                    self.errorMessage = "Erreur de type: \(type), Contexte: \(context)"
                    print("Erreur de type: \(type), Contexte: \(context)")
                case .valueNotFound(let value, let context):
                    self.errorMessage = "Valeur manquante pour \(value), Contexte: \(context)"
                    print("Valeur manquante pour \(value), Contexte: \(context)")
                case .keyNotFound(let key, let context):
                    self.errorMessage = "Clé manquante: \(key), Contexte: \(context)"
                    print("Clé manquante: \(key), Contexte: \(context)")
                case .dataCorrupted(let context):
                    self.errorMessage = "Données corrompues: \(context)"
                    print("Données corrompues: \(context)")
                @unknown default:
                    self.errorMessage = "Erreur inconnue: \(decodingError)"
                    print("Erreur inconnue: \(decodingError)")
                }
            } catch {
                // Gestion d'autres erreurs (autres erreurs de réseau, etc.)
                self.errorMessage = "Erreur lors du chargement des repas avec aliments: \(error.localizedDescription)"
                print("Erreur générique: \(error.localizedDescription)")
            }
            
            // Fin du chargement
            self.isLoading = false
        } catch {
            // Gestion des erreurs réseau (connexion, serveur, etc.)
            self.errorMessage = "Erreur réseau ou serveur: \(error.localizedDescription)"
            print("Erreur réseau: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
}
