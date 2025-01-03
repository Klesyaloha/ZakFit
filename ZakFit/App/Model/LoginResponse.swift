//
//  LoginResponse.swift
//  ZakFit
//
//  Created by Klesya on 16/12/2024.
//

import Foundation

struct LoginResponse: Codable, Sendable {
    let token: String
    let user: User
}
