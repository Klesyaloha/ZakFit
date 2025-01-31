//
//  PhysicalActivityViewModel.swift
//  ZakFit
//
//  Created by Klesya on 05/01/2025.
//

import Foundation
import Combine
import SwiftUICore

class PhysicalActivityViewModel: ObservableObject {
    // Liste des activités physiques associées à l'utilisateur
    @Published var activities: [PhysicalActivity] = []
    @Published var selectedActivity: PhysicalActivity?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @ObservedObject var typeActivityViewModel = TypeActivityViewModel() // Ajout de TypeActivityViewModel

    private let baseURL = "http://192.168.0.199:8080/physical_activities/"

    // Charger toutes les activités pour l'utilisateur connecté
    func fetchActivities() async {
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
        
        // Attendre que les types d'activités soient récupérés avant de continuer
        await typeActivityViewModel.fetchTypeActivities()
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

//            // Affichage de la réponse brute
//            print("Réponse brute du serveur : \(String(data: data, encoding: .utf8) ?? "Aucune donnée valide")")

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // Décode les dates au format ISO8601

            do {
                let decodedActivities = try decoder.decode([PhysicalActivity].self, from: data)
                // Met à jour les activités avec le nom de type d'activité
                var updatedActivities: [PhysicalActivity] = []
                for i in 0..<decodedActivities.count {
                    var activity = decodedActivities[i]
                    
                    // Chercher le type d'activité correspondant dans typeActivities
                    if let typeActivity = typeActivityViewModel.typeActivities.first(where: { $0.id == activity.typeActivity.id }) {
                        // Associer le nom du type d'activité à l'activité
                        activity.typeActivity.nameTypeActivity = typeActivity.nameTypeActivity
                    } else {
                        // Si le type d'activité n'est pas trouvé, assignez "Inconnu"
                        activity.typeActivity.nameTypeActivity = "Inconnu"
                    }
                    
                    // Ajoutez l'activité mise à jour dans votre tableau d'activités
                    updatedActivities.append(activity)
                }
                
                self.activities = updatedActivities
            } catch {
                // Affichage des erreurs détaillées lors du décodage
                print("Erreur de décodage : \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("Données corrompues: \(context)")
                    case .keyNotFound(let key, let context):
                        print("Clé manquante: \(key), contexte: \(context)")
                    case .typeMismatch(let type, let context):
                        print("Incompatibilité de type: \(type), contexte: \(context)")
                    case .valueNotFound(let value, let context):
                        print("Valeur manquante: \(value), contexte: \(context)")
                    @unknown default:
                        print("Erreur inconnue : \(decodingError)")
                    }
                }
                self.errorMessage = "Erreur lors du décodage des activités: \(error.localizedDescription)"
            }
        } catch {
            self.errorMessage = "Erreur lors du chargement des activités: \(error.localizedDescription)"
        }
        self.isLoading = false
    }
    
    
    
    // Ajouter une nouvelle activité
    func addActivity(_ activity: PhysicalActivity) async {
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
        
        // Verification du typeActivity.id
        guard typeActivityViewModel.typeActivities.first(where: { $0.id == activity.typeActivity.id }) != nil else {
            self.errorMessage = "Type d'activité invalide ou inexistant."
            return
        }
        
        let isoFormatter = ISO8601DateFormatter()
        let jsonBody: [String: Any] = [
            "durationActivity": activity.durationActivity,
            "caloriesBurned": activity.caloriesBurned ?? 0,
            "dateActivity": isoFormatter.string(from: activity.dateActivity), // Format ISO 8601
            "typeActivityID": activity.typeActivity.id.uuidString
        ]
        
        do {
            // Serialization
            let jsonData = try JSONSerialization.data(withJSONObject: jsonBody)
            request.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                throw URLError(.badServerResponse)
            }
        } catch {
            self.errorMessage = "Erreur lors de l'ajout de l'activité: \(error.localizedDescription)"
        }
    }
    
    // Mettre à jour une activité existante
    func updateActivity(_ activity: PhysicalActivity) async {
        guard let token = KeychainManager.getTokenFromKeychain() else {
            self.errorMessage = "Token manquant. Veuillez vous reconnecter."
            return
        }
        guard let url = URL(string: "\(baseURL)\(activity.id.uuidString)") else {
            self.errorMessage = "URL ou ID invalide."
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let isoFormatter = ISO8601DateFormatter()
        let jsonBody: [String: Any] = [
            "durationActivity": activity.durationActivity,
            "caloriesBurned": activity.caloriesBurned ?? 0,
            "dateActivity": isoFormatter.string(from: activity.dateActivity), // Format ISO 8601
            "typeActivityID": activity.typeActivity.id.uuidString
        ]
        
        do {
            // Serialization
            let jsonData = try JSONSerialization.data(withJSONObject: jsonBody)
            request.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
//            await fetchActivities() // Recharge la liste après mise à jour
        } catch {
            self.errorMessage = "Erreur lors de la mise à jour de l'activité: \(error.localizedDescription)"
        }
    }
    
    // Supprimer une activité
    func deleteActivity(_ activityID: UUID) async {
        guard let token = KeychainManager.getTokenFromKeychain() else {
            self.errorMessage = "Token manquant. Veuillez vous reconnecter."
            return
        }
        
        guard let url = URL(string: "\(baseURL)\(activityID.uuidString)") else {
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
            
            self.activities.removeAll { $0.id == activityID }
        } catch {
            self.errorMessage = "Erreur lors de la suppression de l'activité: \(error.localizedDescription)"
        }
    }
}
