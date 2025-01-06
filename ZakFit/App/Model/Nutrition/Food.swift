//
//  Food.swift
//  ZakFit
//
//  Created by Klesya on 06/01/2025.
//

import Foundation

struct Food: Codable, Identifiable, @unchecked Sendable {
    var id: UUID
    var nameFood: String
    var quantityFood: Double
    var proteins: Double
    var carbs: Double
    var fats: Double
    var caloriesByFood: Double
}
