//
//  ZakFitApp.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import SwiftUI

@main
struct ZakFitApp: App {
    
    init() {
        // Change la couleur du titre dans toutes les vues avec une navigation bar
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor.accent
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.accent
        ]
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
