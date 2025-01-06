//
//  Meal.swift
//  ZakFit
//
//  Created by Klesya on 06/01/2025.
//

import Foundation

struct Meal: Codable, Identifiable, @unchecked Sendable {
    var id: UUID
    var nameMeal: String
    var typeOfMeal: String
    var quantityMeal: Double
    var dateMeal: Date
    var caloriesByMeal: Double
    var user: PartialUserUpdate  // Relation avec l'utilisateur (comme dans PhysicalActivity)
    
    // Propriété calculée pour formater la date
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM yyyy" // Format "Jour x Mois 2025"
        dateFormatter.locale = Locale(identifier: "fr_FR") // Locale français
        return dateFormatter.string(from: dateMeal)
    }
    
    // Initialiseur personnalisé pour gérer les données manquantes
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        nameMeal = try container.decode(String.self, forKey: .nameMeal)
        typeOfMeal = try container.decode(String.self, forKey: .typeOfMeal)
        quantityMeal = try container.decode(Double.self, forKey: .quantityMeal)
        dateMeal = try container.decode(Date.self, forKey: .dateMeal)
        caloriesByMeal = try container.decode(Double.self, forKey: .caloriesByMeal)
        user = try container.decode(PartialUserUpdate.self, forKey: .user)
    }
    
    init(nameMeal: String, typeOfMeal: String, quantityMeal: Double, dateMeal: Date, caloriesByMeal: Double, user: PartialUserUpdate) {
        self.id = UUID()
        self.nameMeal = nameMeal
        self.typeOfMeal = typeOfMeal
        self.quantityMeal = quantityMeal
        self.dateMeal = dateMeal
        self.caloriesByMeal = caloriesByMeal
        self.user = user
    }
}

