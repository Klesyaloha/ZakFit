//
//  ContentView.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = UserViewModel()
    @State private var selectedHealthGoal: String = "Aucun" // Initialiser avec la valeur par défaut (tag(1))
    let options = ["Aucun", "Perte de poids", "Prise de masse", "Maintien"]
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello \(viewModel.currentUser.nameUser)")
            
            ForEach(Array(options.prefix(3).enumerated()), id: \.0) { index, preference in
                Text("\(index) : \(preference)")
                    .padding(.vertical, 2)
            }
            .padding()
            .onAppear(perform: {
                Task {
                    await viewModel.login()
                }
            })
        }
    }
}

#Preview {
    ContentView()
}
