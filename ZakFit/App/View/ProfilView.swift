//
//  ProfilView.swift
//  ZakFit
//
//  Created by Klesya on 16/12/2024.
//

import SwiftUI

struct ProfilView: View {
    @EnvironmentObject var viewModel : UserViewModel
    @State var EditName: Bool = false
    @State var EditSurname: Bool = false
    @State var EditEmail: Bool = false
    @State var EditPassword: Bool = false
    @State var passwordIsVisible: Bool = false
    @State private var isHovered = false
    @State private var selectedHealthGoal: String = "Aucun" // Initialiser avec la valeur par défaut (tag(1))
    let options = ["Aucun", "Perte de poids", "Prise de masse", "Maintien"]
    let foodPreferences = [
        "Viande",
        "Poisson",
        "Origine animale",
        "Aliments crus",
        "Produits locaux",
        "Gluten"
    ]
    
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
                    ProfilComponentUser(title: "Nom :", content: $viewModel.currentUser.surname, ifEdit: EditSurname)
                        .padding(.top, 18)
                    
                    ProfilComponentUser(title: "Prénom :", content: $viewModel.currentUser.nameUser, ifEdit: EditName)
                    
                    ProfilComponentUser(title: "Email :", content: $viewModel.currentUser.email, ifEdit: EditEmail)
                    
                    ProfilComponentUser(title: "Mot de Passe :", content: $viewModel.currentUser.email, ifEdit: EditEmail, isVisible: passwordIsVisible)
                
                    VStack(spacing: 0) {
                        HStack(spacing: 10) {
                            Text("Taille")
                                .bold()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Button(action: {
                                    viewModel.changeUserProperty("sizeUser", "-")
                                }, label: {
                                    Image(systemName: "minus")
                                        .bold()
                                })
                                
                                TextField(value: $viewModel.currentUser.sizeUser, format: .number, label: {
                                    Text("\(viewModel.currentUser.sizeUser,  specifier: "%.1f")")
                                })
                                .multilineTextAlignment(.center)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .frame(width: 50, alignment: .center)
                                
                                Button(action: {
                                    viewModel.changeUserProperty("sizeUser", "+")
                                }, label: {
                                    Image(systemName: "plus")
                                        .bold()
                                })
                            }
                            .foregroundStyle(.grey)
                            .padding()
                            .background{
                                Rectangle()
                                    .frame(height: 30)
                                    .foregroundStyle(.white)
                                    .cornerRadius(24)
                            }
                        }
                        
                        HStack(spacing: 10) {
                            Text("Poids")
                                .bold()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Button(action: {
                                    viewModel.changeUserProperty("weight", "-")
                                }, label: {
                                    Image(systemName: "minus")
                                        .bold()
                                })
                                
                                TextField(value: $viewModel.currentUser.weight, format: .number, label: {
                                    Text("\(viewModel.currentUser.weight,  specifier: "%.1f")")
                                })
                                .multilineTextAlignment(.center)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .frame(width: 50, alignment: .center)
                                
                                Button(action: {
                                    viewModel.changeUserProperty("weight", "+")
                                }, label: {
                                    Image(systemName: "plus")
                                        .bold()
                                })
                            }
                            .foregroundStyle(.grey)
                            .padding()
                            .background{
                                Rectangle()
                                    .frame(height: 30)
                                    .foregroundStyle(.white)
                                    .cornerRadius(24)
                            }
                        }
                        
                        HStack(spacing: 10) {
                            Text("Objectifs de Santé")
                                .bold()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Menu {
                                ForEach(options.indices, id: \.self) { index in
                                    Button(action: {
                                        viewModel.changeUserProperty("healthChoice", String(index))
                                    }) {
                                        Text(options[index])
                                            .font(.system(size: 16, weight: .regular)) // Personnalisation
                                            .foregroundColor(.grey) // Couleur personnalisée
                                    }
                                }
                            } label: {
                                Text(options[viewModel.currentUser.healthChoice])
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 32)
                            }
                            .accentColor(.grey)
                            .font(.system(size: 15, weight: .semibold))
                            .frame(width: 135, alignment: .trailing)
                            .background(.white)
                            .cornerRadius(25)
                            .padding(.vertical, 13)
                        }
                        
                        VStack {
                            Text("Préférences Alimentaires")
                                .bold()
                                .padding(.top, 13)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 329, height: 103)
                                    .background(.white)

                                    .cornerRadius(16)
                                
                                HStack(spacing: 0) {
                                    VStack(spacing: 3) {
                                        ForEach(0...2, id: \.self) { index in
                                            HStack(spacing: 3) {
                                                Button(action: {
                                                    viewModel.updateEatChoice(index: index)
                                                }, label: {
                                                    Image(systemName: viewModel.currentUser.eatChoice.contains(where: { $0 == index}) ? "checkmark.square.fill" : "square")
                                                        .font(.system(size: 17, weight: .semibold))
                                                })
                                                Text(foodPreferences[index])
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                        .foregroundStyle(.grey)
                                        .padding(.leading, 20)
                                    }
                                    
                                    VStack(spacing: 3) {
                                        ForEach(3...5, id: \.self) { index in
                                            HStack(spacing: 3) {
                                                Button(action: {
                                                    viewModel.updateEatChoice(index: index)
                                                }, label: {
                                                    Image(systemName: viewModel.currentUser.eatChoice.contains(where: { $0 == index}) ? "checkmark.square.fill" : "square")
                                                        .font(.system(size: 17, weight: .semibold))
                                                })
                                                Text(foodPreferences[index])
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                        .foregroundStyle(.grey)
                                        .padding(.leading, 20)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    await viewModel.updateUserData()
                                }
//                                Task {
//                                    await viewModel.login()
//                                    await viewModel.fetchUserData(userID: viewModel.currentUser.idUser)
//                                }
                            }, label: {
                                Text("Modifier mes informations")
                                    .bold()
                                    .padding()
                                    .background(.grey)
                                    .cornerRadius(24)
                                    .foregroundStyle(.white)
                            })
                            
                            Spacer()
                        }
                    }
                    .padding(.all, 30)
                    .background(content: {
                        Rectangle()
                            .frame(width: 402)
                            .cornerRadius(49)
                            .foregroundStyle(.grey)
                            .opacity(0.5)
                    })
                    .padding(.top, 30)
                    
                    Spacer()
                    
                }
                .navigationTitle("Mon Profil")
                .toolbar {
                    // Modifier la couleur du titre de la navigation bar
                    ToolbarItem(placement: .topBarLeading) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 99.36239, height: 33.31912)
                            .frame(alignment: .leading)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewModel.logout()
                        }, label: {
                            Image(systemName: "power")
                                .foregroundStyle(.red)
                                .padding(.trailing, 10)
                        })
                    }
                }
            }
            // Ajouter l'alerte
            .alert(isPresented: $viewModel.showUpdateAlert) {
                Alert(
                    title: Text("Mise à jour réussie"),
                    message: Text(viewModel.alertUpdateMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
//            .onChange(of: viewModel, {
//                viewModel.updateUserData()
//            })
//            .onAppear(perform: {
//                Task {
//                    await viewModel.fetchUserData(userID: userId)
//                }
//            })
            .onDisappear(perform: {
                
            })
        }
    }
}

#Preview {
    ProfilView()
        .environmentObject(UserViewModel())
}

struct ProfilComponentUser : View {
    var title : String
    @Binding var content : String
    @State var ifEdit : Bool
    @State var isVisible : Bool?
    var spaceComponents : CGFloat = 13
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: (UIScreen.main.bounds.width / 2) - 65, height: spaceComponents, alignment: .leading)
                .padding(.leading, 25)
                .frame(alignment: .leading)
                .bold()
                .foregroundStyle(.grey)
                .font(.system(size: 16))
            
            if ifEdit {
                TextField(text: $content, label: {
                    Text(content)
                    
                })
                .frame(height: spaceComponents)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .fontWeight(.medium)
                .foregroundStyle(.grey)
                .font(.system(size: 15))
            } else {
                Text(content)
                    .frame(height: spaceComponents)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .fontWeight(.medium)
                    .foregroundStyle(.grey)
                    .font(.system(size: 15))
                    .onTapGesture(perform: {
                        self.ifEdit.toggle()
                    })
            }
            
            if title == "Mot de Passe :" {
                
                Button(action: {
                    self.isVisible?.toggle()
                }) {
                    Image(systemName: isVisible ?? false ? "eye" : "eye.slash")
                        .padding(.trailing, 30)
                        .foregroundStyle(.grey)
                }
                .frame(height: spaceComponents)
            }
        }
    }
}
