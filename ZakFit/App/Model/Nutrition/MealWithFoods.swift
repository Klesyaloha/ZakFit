//
//  MealWithFoods.swift
//  ZakFit
//
//  Created by Klesya on 06/01/2025.
//

import Foundation

struct MealWithFoods: Codable, Identifiable {
    var id: UUID
    var meal: Meal
    var foods: [Food]
}
