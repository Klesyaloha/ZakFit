//
//  PhysicalActivity.swift
//  ZakFit
//
//  Created by Klesya on 05/01/2025.
//

import Foundation

struct PhysicalActivity: Codable, Identifiable, @unchecked Sendable {

    var id: UUID
    var durationActivity: Double
    var caloriesBurned: Double?
    var dateActivity: Date
    var typeActivity: TypeActivity // Pour la relation, on stocke l'ID
    var user: PartialUserUpdate // Pour la relation, on stocke l'ID
    
    // Propriété calculée pour formater la date
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM yyyy" // Format "Jour x Mois 2025"
        dateFormatter.locale = Locale(identifier: "fr_FR") // Définir la locale en français
        return dateFormatter.string(from: dateActivity)
    }
    
    // Initialiseur personnalisé pour gérer les données manquantes
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        durationActivity = try container.decode(Double.self, forKey: .durationActivity)
        caloriesBurned = try container.decodeIfPresent(Double.self, forKey: .caloriesBurned)
        dateActivity = try container.decode(Date.self, forKey: .dateActivity)
        typeActivity = try container.decode(TypeActivity.self, forKey: .typeActivity)
        user = try container.decode(PartialUserUpdate.self, forKey: .user)
    }
    
    init(durationActivity: Double, caloriesBurned: Double?, dateActivity: Date, typeActivity: TypeActivity, user: PartialUserUpdate) {
        self.id = UUID()
        self.durationActivity = durationActivity
        self.caloriesBurned = caloriesBurned
        self.dateActivity = dateActivity
        self.typeActivity = typeActivity
        self.user = user
    }
}
