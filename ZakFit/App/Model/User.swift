//
//  User.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import Foundation

class User: Codable, ObservableObject, @unchecked Sendable {
    var idUser: UUID
    var nameUser: String
    var surname: String
    var email: String
    var password: String?
    var sizeUser: Double
    var weight: Double
    var healthChoice: Int
    var eatChoice: [Int]
    
    init() {
        idUser = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        nameUser = ""
        surname = ""
        email = "alice.johnson@test.com"
        password = "hashed_password_3"
        sizeUser = 0.0
        weight = 0.0
        healthChoice = 0
        eatChoice = []
    }
    
    // Initialiseur personnalisé
    init(idUser: UUID, nameUser: String, surname: String, email: String, password: String? = nil, sizeUser: Double, weight: Double, healthChoice: Int, eatChoice: [Int]) {
        self.idUser = idUser
        self.nameUser = nameUser
        self.surname = surname
        self.email = email
        self.password = password
        self.sizeUser = sizeUser
        self.weight = weight
        self.healthChoice = healthChoice
        self.eatChoice = eatChoice
    }
    
    // Gestion de la différence de clé entre le front et le back
    enum CodingKeys: String, CodingKey {
        case idUser = "id" // Correspondance entre 'idUser' (front) et 'id' (back)
        case nameUser
        case surname
        case email
        case sizeUser
        case weight
        case healthChoice
        case eatChoice
    }
}

