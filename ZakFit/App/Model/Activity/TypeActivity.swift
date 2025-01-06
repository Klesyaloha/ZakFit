//
//  TypeActivity.swift
//  ZakFit
//
//  Created by Klesya on 05/01/2025.
//

import Foundation

struct TypeActivity: Codable, Identifiable, @unchecked Sendable {

    var id: UUID // Non optionnel côté front une fois récupéré du back
    var nameTypeActivity: String?

    init() {
        self.id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")! // UUID par défaut pour les initialisations vides
        self.nameTypeActivity = ""
    }

    init(id: UUID, nameTypeActivity: String) {
        self.id = id
        self.nameTypeActivity = nameTypeActivity
    }
}
