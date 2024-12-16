//
//  ContentView.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = UserViewModel()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello \(viewModel.nameUser)")
        }
        .padding()
        .onAppear(perform: {
            Task {
                await viewModel.login()
            }
        })
    }
}

#Preview {
    ContentView()
}
