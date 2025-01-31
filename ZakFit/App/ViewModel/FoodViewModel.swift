//
//  FoodViewModel.swift
//  ZakFit
//
//  Created by Klesya on 06/01/2025.
//

import Foundation
import SwiftUI

class FoodViewModel: ObservableObject, @unchecked Sendable {
    @Published var foods: [Food] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://192.168.0.199:8080/foods/"
    
    func fetchFoods() async {
        guard let token = KeychainManager.getTokenFromKeychain() else {
            self.errorMessage = "Token manquant. Veuillez vous reconnecter."
            return
        }
        
        guard let url = URL(string: baseURL) else {
            self.errorMessage = "URL invalide."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // Décode les dates au format ISO8601
            
            do {
                let decodedFoods = try decoder.decode([Food].self, from: data)
                DispatchQueue.main.async {
                    self.foods = decodedFoods
//                    print("Aliments récupérés")
                }
            }
        } catch {
            DispatchQueue.main.async {
                // Affichage des erreurs détaillées lors du décodage
                print("Erreur lors de la récupération des aliments: \(error.localizedDescription)")
            }
        }
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func addFood(_ food: Food) async {
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
        
        do {
            let jsonData = try JSONEncoder().encode(food)
            request.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                throw URLError(.badServerResponse)
            }
        } catch {
            self.errorMessage = "Erreur lors de l'ajout de l'aliment: \(error.localizedDescription)"
        }
    }
}
