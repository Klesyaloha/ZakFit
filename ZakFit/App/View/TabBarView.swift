//
//  TabBarView.swift
//  ZakFit
//
//  Created by Klesya on 03/01/2025.
//

import SwiftUI

enum Tab: String {
    case home = "Dashboard"
    case activities = "Activités"
    case food = "Nutrition"
    case acts = "Performances"
    case profil = "Profil"
}

struct TabBarView: View {
    @EnvironmentObject var viewModel : UserViewModel
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Contenu du Tableau de Bord")
                .tabItem {
                    Image(systemName: "list.clipboard.fill")
                    Text(Tab.home.rawValue)
                }
                .tag(Tab.home)

            Text("Contenu des Activités")
                .tabItem {
                    Image(systemName: "figure.run")
                    Text(Tab.activities.rawValue)
                }
                .tag(Tab.activities)

            Text("Contenu Nutrition")
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text(Tab.food.rawValue)
                }
                .tag(Tab.food)

            Text("Contenu Performances")
                .tabItem {
                    Image(systemName: "medal.fill")
                    Text(Tab.acts.rawValue)
                }
                .tag(Tab.acts)
            ProfilView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text(Tab.profil.rawValue)
                }
                .tag(Tab.profil)
        }
        .accentColor(Color.accent)
    }
}

#Preview {
    TabBarView()
        .environmentObject(UserViewModel())
}

