//
//  KeychainManager.swift
//  ZakFit
//
//  Created by Klesya on 11/12/2024.
//

import Foundation
import Security

struct KeychainManager {
    static func saveTokenToKeychain(_ token: String) -> Bool{
        
        //Convertir le token en données
        guard let tokenData = token.data(using: .utf8) else { return false }
        
        // Créer un dictionnaire de requête pour le trousseau
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "token",
            kSecValueData as String: tokenData
        ]
        
        //Supprimer l'entrée existante, si elle existe
        SecItemDelete(query as CFDictionary)
        
        // Ajouter le token dans le trousseau
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    static func getTokenFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "token",
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }
    
    static func deleteTokenFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "token"
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
