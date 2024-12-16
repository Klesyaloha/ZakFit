//
//  UserRegistrationRequest.swift
//  ZakFit
//
//  Created by Klesya on 14/12/2024.
//

import Foundation

struct UserRegistrationRequest: Encodable {
    let nameUser: String
    let surname: String
    let email: String
    let password: String
    let size: Double?
    let weight: Double?
    let healthChoice: Int?
    let eatChoice: [Int]?
}
