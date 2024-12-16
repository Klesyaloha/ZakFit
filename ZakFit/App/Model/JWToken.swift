//
//  JWToken.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import Foundation

struct JWToken: Codable {
    var value: String
    
    enum CodingKeys: String, CodingKey {
        case value = "token"
    }
}

