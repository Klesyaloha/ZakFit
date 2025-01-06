//
//  Composition.swift
//  ZakFit
//
//  Created by Klesya on 06/01/2025.
//

import Foundation
import SwiftUI

struct Composition: Codable, Identifiable, @unchecked Sendable {

    var id: UUID
    var quantity: Double
    var food: PartialFood  // Relation avec l'aliment (par exemple, un aliment avec son ID et éventuellement d'autres propriétés)
    var meal: PartialMeal  // Relation avec le repas (même principe qu'avec l'aliment)
    
    // Initialiseur personnalisé pour gérer les données manquantes
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        quantity = try container.decode(Double.self, forKey: .quantity)
        food = try container.decode(PartialFood.self, forKey: .food)
        meal = try container.decode(PartialMeal.self, forKey: .meal)
    }
    
    init(id: UUID? = nil, quantity: Double, food: PartialFood, meal: PartialMeal) {
        self.id = id ?? UUID()
        self.quantity = quantity
        self.food = food
        self.meal = meal
    }
}

// Struct pour représenter un aliment partiel (juste un ID ou d'autres propriétés si nécessaire)
struct PartialFood: Codable {
    let id: UUID
    let name: String
}

// Struct pour représenter un repas partiel (comme dans le modèle Meal)
struct PartialMeal: Codable {
    let id: UUID
    let nameMeal: String
}

// Pour l'utilisation dans des réponses JSON, tu peux avoir des structures comme ceci :
struct PartialComposition: Codable {
    let foodId: UUID
    let mealId: UUID
    var quantity: Double
}


