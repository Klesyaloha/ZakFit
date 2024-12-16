//
//  LoginView.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = UserViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image("logo_lauch_screen")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 348.0, height: 167.0)
                
                TextField(text: $viewModel.email, label: {
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
                
                TextField(text: $viewModel.password, label: {
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
                
                if let error = viewModel.loginError {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                ContentView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    LoginView()
}
