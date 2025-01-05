//
//  LoginView.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel : UserViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Image("logo_lauch_screen")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 365, height: 365)
                        .padding(.top, 145.0)
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                        .frame(height: 400)
                    
                    TextField(text: $viewModel.currentUser.email, label: {
                        Text("Email")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.system(size: 13))
                    })
                    .autocapitalization(.none)
                    .padding()
                    .font(.system(size: 13))
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
                    .font(.system(size: 13))
                    .frame(width: 187, height: 49)
                    .background(.grey)
                    .foregroundStyle(.white)
                    .cornerRadius(24)
                    
                    NavigationLink(destination: {
                        RegisterView()
                            .navigationBarBackButtonHidden()
                    }, label: {
                        HStack {
                            Text("Pas encore Zakcolite ?")
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                            
                            Text("M'inscrire")
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                                .foregroundStyle(.accent)
                                .underline(true, pattern: .solid)
                        }
                    })
                    
                    Button(action: {
                        Task {
                            await viewModel.login()
                        }
                    }, label: {
                        Text("Entrer")
                            .padding()
                            .font(.system(size: 14))
                            .bold()
                            .foregroundStyle(.white)
                            .frame(width: 127, height: 37)
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
                    .padding(.top, 10)
                    
                    // Gestion erreur d'authentification (email, mdp, serveur)
                    if !isValidEmail(viewModel.currentUser.email) && viewModel.currentUser.password == "" {
                        Text("Email et mot de passe invalides")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    } else if !isValidEmail(viewModel.currentUser.email) {
                        Text("Email invalide")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    } else if viewModel.currentUser.password == "" {
                        Text("Mot de passe requis")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    } else if let error = viewModel.loginError {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                }
                // Navigation vers la page profil
                .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                    TabBarView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
    // Verifie le format de l'email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    LoginView()
        .environmentObject(UserViewModel()) // Injecter l'instance de UserViewModel dans l'environnement
}
