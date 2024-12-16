//
//  User.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import Foundation

struct User: Codable {
    let idUser: String?
    var nameUser: String
    var surname: String
    var email: String
    var password: String?
    var size: Double?
    var weight: Double?
    var healthChoice: Int?
    var eatChoice: [Int]?
}

