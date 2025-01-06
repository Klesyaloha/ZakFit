//
//  RegisterView.swift
//  ZakFit
//
//  Created by Klesya on 13/12/2024.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss // Permet de gérer le retour en arrière
    
    @EnvironmentObject var viewModel : UserViewModel
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Image("logo_lauch_screen")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 365, height: 365)
                        .padding(.top, 60)
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                        .frame(height: 330)
                    
                    TextField(text: $viewModel.currentUser.surname, label: {
                        Text("Nom")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.system(size: 13))
                    })
                    .autocapitalization(.none)
                    .padding()
                    .frame(width: 187, height: 49)
                    .background(.grey)
                    .foregroundStyle(.white)
                    .cornerRadius(24)
                    
                    TextField(text: $viewModel.currentUser.nameUser, label: {
                        Text("Prénom")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.system(size: 13))
                    })
                    .autocapitalization(.none)
                    .padding()
                    .frame(width: 187, height: 49)
                    .background(.grey)
                    .foregroundStyle(.white)
                    .cornerRadius(24)
                    
                    TextField(text: $viewModel.currentUser.email, label: {
                        Text("Email")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.system(size: 13))
                    })
                    .autocapitalization(.none)
                    .padding()
                    .frame(width: 187, height: 49)
                    .background(.grey)
                    .foregroundStyle(.white)
                    .cornerRadius(24)
                    
                    TextField(text: Binding(
                        get: { viewModel.currentUser.password ?? "" },
                        set: { viewModel.currentUser.password = $0 }), label: {
                        Text("Mot de Passe")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.system(size: 13))
                    })
                    .autocapitalization(.none)
                    .padding()
                    .frame(width: 187, height: 49)
                    .background(.grey)
                    .foregroundStyle(.white)
                    .cornerRadius(24)
                    
                    Button(action: {
                        dismiss() // Ferme la vue actuelle
                    }, label: {
                        Text("Je suis déjà membre")
                            .font(.system(size: 10))
                            .fontWeight(.semibold)
                            .foregroundStyle(.accent)
                            .underline(true, pattern: .solid)
                    })
                    
                    Button(action: {
                        Task {
                            await viewModel.register()
                            await viewModel.login()
                        }
                    }, label: {
                        Text("Je deviens Zakcolite")
                            .padding()
                            .font(.system(size: 14))
                            .bold()
                            .foregroundStyle(.white)
                            .frame(width: 187, height: 37)
                            .background(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: Color(red: 0.45, green: 0.45, blue: 0.45), location: 0.00),
                                        Gradient.Stop(color: Color(red: 1, green: 0.44, blue: 0), location: 1.00),
                                    ],
                                    startPoint: UnitPoint(x: 0.11, y: -0.41),
                                    endPoint: UnitPoint(x: 0.94, y: 1.35)
                                )
                            )
                            .cornerRadius(24)
                    })
                    .padding(.top, 16)
                    
                    Spacer()
                }
                .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                    TabBarView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(UserViewModel())
}
