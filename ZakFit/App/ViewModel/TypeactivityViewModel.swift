//
//  TypeactivityViewModel.swift
//  ZakFit
//
//  Created by Klesya on 05/01/2025.
//

import Foundation
import SwiftUI

class TypeActivityViewModel: ObservableObject, @unchecked Sendable {
    @Published var typeActivities: [TypeActivity] = []
    @Published var errorMessage: String?
    private let baseURL = "http://127.0.0.1:8080/type_activities/"
    
    // Fonction pour charger tous les types d'activités
    func fetchTypeActivities() async {
        guard let url = URL(string: baseURL) else {
            self.errorMessage = "URL invalide."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Effectuer la requête réseau
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Vérifier la réponse HTTP
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Erreur HTTP : \(httpResponse.statusCode)"
                    }
//                    // Debug : afficher la réponse brute en cas d'erreur
//                    print("Réponse brute : \(String(data: data, encoding: .utf8) ?? "Non décodable")")
                    return
                }
            }
            
//            // Debug : afficher les données brutes reçues
//            print("Réponse brute : \(String(data: data, encoding: .utf8) ?? "Non décodable")")
            
            // Vérifier s'il y a une erreur dans la réponse JSON
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonDict = jsonObject as? [String: Any],
               jsonDict["error"] as? Bool == true {
                print("Erreur côté serveur : \(jsonDict["reason"] ?? "Raison inconnue")")
                return
            }
            
            // Décoder les types d'activités
            let decodedTypeActivities = try JSONDecoder().decode([TypeActivity].self, from: data)
            
            // Mettre à jour la liste des types d'activités
            DispatchQueue.main.async {
                self.typeActivities = decodedTypeActivities
                print("Types d'activités mis à jour : \(self.typeActivities)")
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Erreur lors du chargement des types d'activités : \(error.localizedDescription)"
            }
        }
    }
}
