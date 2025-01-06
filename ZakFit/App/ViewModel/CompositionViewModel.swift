//
//  CompositionViewModel.swift
//  ZakFit
//
//  Created by Klesya on 06/01/2025.
//

import Foundation
import Combine
import SwiftUICore

class CompositionViewModel: ObservableObject {
    // Liste des compositions associées aux repas
    @Published var compositions: [Composition] = []
    @Published var selectedComposition: Composition?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://127.0.0.1:8080/compositions/"
    
    // Charger toutes les compositions d'un utilisateur
    func fetchCompositions() async {
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

        self.isLoading = true
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

//            // Affichage de la réponse brute pour déboguer
//            print("Réponse brute du serveur : \(String(data: data, encoding: .utf8) ?? "Aucune donnée valide")")

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // Décode les dates au format ISO8601

            do {
                let decodedCompositions = try decoder.decode([Composition].self, from: data)
                print("Compositions décodées : \(decodedCompositions)")
                
                // Mettre à jour la liste des compositions
                self.compositions = decodedCompositions
            } catch {
//                // Affichage des erreurs détaillées lors du décodage
//                print("Erreur de décodage : \(error.localizedDescription)")
                self.errorMessage = "Erreur lors du décodage des compositions: \(error.localizedDescription)"
            }
        } catch {
            self.errorMessage = "Erreur lors du chargement des compositions: \(error.localizedDescription)"
        }
        self.isLoading = false
    }
    
    // Ajouter une composition
    func addComposition(_ composition: Composition) async {
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
            let jsonData = try JSONEncoder().encode(composition)
            request.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                throw URLError(.badServerResponse)
            }
            await fetchCompositions() // Recharge la liste des compositions après ajout
        } catch {
            self.errorMessage = "Erreur lors de l'ajout de la composition: \(error.localizedDescription)"
        }
    }
    
    // Supprimer une composition
    func deleteComposition(_ compositionID: UUID) async {
        guard let token = KeychainManager.getTokenFromKeychain() else {
            self.errorMessage = "Token manquant. Veuillez vous reconnecter."
            return
        }
        
        guard let url = URL(string: "\(baseURL)\(compositionID.uuidString)") else {
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
            
            self.compositions.removeAll { $0.id == compositionID }
        } catch {
            self.errorMessage = "Erreur lors de la suppression de la composition: \(error.localizedDescription)"
        }
    }
}

