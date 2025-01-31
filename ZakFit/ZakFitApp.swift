//
//  ZakFitApp.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import SwiftUI

@main
struct ZakFitApp: App {
    @StateObject var userViewModel = UserViewModel()
    @StateObject var physicalActivityViewModel = PhysicalActivityViewModel()
    @StateObject var typeActivityViewModel = TypeActivityViewModel()
    @StateObject var mealViewModel = MealViewModel()
    @StateObject var foodViewModel = FoodViewModel()
    @StateObject var compositionViewModel = CompositionViewModel()
    
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
            if !userViewModel.isLoggedIn {
                LoginView()
            }
            else {
                TabBarView()
            }
            
        }
        .environment(\.locale, Locale(identifier: "fr_FR")) // Remplace par la locale souhaitée
        .environmentObject(userViewModel)
        .environmentObject(physicalActivityViewModel)
        .environmentObject(typeActivityViewModel)
        .environmentObject(mealViewModel)
        .environmentObject(foodViewModel)
        .environmentObject(compositionViewModel)
    }
}
