//
//  ProfilView.swift
//  ZakFit
//
//  Created by Klesya on 16/12/2024.
//

import SwiftUI

struct ProfilView: View {
    @StateObject var viewModel = UserViewModel()
    @State var EditName: Bool = false
    @State var EditSurname: Bool = false
    @State var EditEmail: Bool = false
    @State var Editweight: Bool = false
    @State private var isHovered = false
    var body: some View {
        NavigationStack {
            ZStack {
                
                LinearGradient(
                stops: [
                Gradient.Stop(color: .white, location: 0.00),
                Gradient.Stop(color: Color(red: 1, green: 0.44, blue: 0), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0.15),
                endPoint: UnitPoint(x: 0.5, y: 1)
                )
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Nom : ")
                            
                            Text("Prénom : ")
                            
                            Text("Email : ")
                            
                            Text("Mot de passe : ")
                            
                        }
                        .frame(alignment: .leading)
                        .bold()
                        .foregroundStyle(.grey)
                        .font(.system(size: 15))
                        
                        VStack(alignment: .leading) {
                            Text(viewModel.surname.uppercased())
                            
                            Text(viewModel.nameUser)
                            
                            Text(viewModel.email)
                            
                            Text("viewModel.email")
                        }
                        .lineLimit(1)
                        .fontWeight(.medium)
                        .foregroundStyle(.grey)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity)
                        .padding(.leading, -16)
                        
                        VStack(alignment: .leading) {
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            })
                            
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            })
                            
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            })
                            
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            })
                        }
                        .onHover { hovering in
                            isHovered.toggle()
                        }
                        .frame(alignment: .trailing)
                        .padding(.trailing)
                        .fontWeight(.medium)
                        .foregroundStyle(isHovered ? .accent : .grey)
                        .font(.system(size: 15))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.bottom, 16)
                    
                    Rectangle()
                        .frame(width: 402, height: 517)
                        .cornerRadius(49)
                        .foregroundStyle(.grey)
                        .opacity(0.5)
                }
                .navigationTitle("Mon Profil")
                .toolbar {
                    // Modifier la couleur du titre de la navigation bar
                    ToolbarItem(placement: .topBarLeading) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.leading, 0)
                            .frame(alignment: .leading)
                    }
                }
            }
            .onAppear(perform: {
                Task {
                    await viewModel.login()
                }
            })
        }
    }
}

#Preview {
    ProfilView()
}

struct ComponentPrincipalInfos: View {
    @State var title: String
    @State var data : String
    var body: some View {
        HStack {
            Text(title)
                .bold()
            Text(data)
                .fontWeight(.medium)
        }
        .foregroundStyle(.grey)
        .font(.system(size: 15))
    }
}
