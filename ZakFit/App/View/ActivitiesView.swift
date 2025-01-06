//
//  ActivitiesView.swift
//  ZakFit
//
//  Created by Klesya on 04/01/2025.
//

import SwiftUI

struct ActivitiesView: View {
    @EnvironmentObject var viewModel : PhysicalActivityViewModel
    @EnvironmentObject var typeActivityViewModel : TypeActivityViewModel
    
    @State var addOverlay : Bool = false
    
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
                .ignoresSafeArea(edges: [.top, .horizontal]) // Ignore le haut et les côtés
               
                VStack {
                    VStack(spacing: 3) {
                        ForEach(Dictionary(grouping: viewModel.activities, by: { $0.formattedDate }).keys.sorted().reversed(), id: \.self) { date in
                            VStack(spacing: 3) {
                                // Afficher la date (une seule fois pour chaque groupe)
                                Text(date)
                                    .frame(maxWidth: .infinity ,alignment: .leading)
                                    .padding(.leading, 16)
                                    .foregroundStyle(.accent)
                                    .font(.system(size: 14, weight: .bold))
                                
                                // Afficher les activités pour cette date
                                ForEach(viewModel.activities.filter { $0.formattedDate == date }) { activity in
                                    HStack {
                                        Spacer()
                                            
                                        Text(activity.typeActivity.nameTypeActivity ?? "Inconnu")
                                            .font(.system(size: 16, weight: .semibold))
                                            .lineLimit(1)
                                            .foregroundStyle(.white)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        
                                        Spacer()
                                            .frame(width: 40, alignment: .center)
                                        
                                        Text("\(Int(activity.durationActivity))min")
                                            .font(.system(size: 15))
                                            .foregroundStyle(.white)
                                        
                                        Spacer()
                                            .frame(width: 40, alignment: .center)
                                        
                                        Text("-\(Int(activity.caloriesBurned ?? 0))cal")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(.grey)
                                            .frame(width: 83, alignment: .center)
                                        Spacer()
                                    }
                                    .background {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 351, height: 43)
                                            .background(Color(red: 0.9, green: 0.6, blue: 0.36).opacity(0.39))
                                            .cornerRadius(12)
                                    }
                                    .padding(.horizontal)
                                }.padding()
                            }
                        }
                    }
                    
                    Spacer()
                }
                .onAppear {
                    Task {
                        await viewModel.fetchActivities()
                        await typeActivityViewModel.fetchTypeActivities()
                    }
                }
                .navigationTitle("Mes Activités")
                .overlay(content: {
                    if addOverlay {
                        VStack {
                            Spacer()
                            AddActivityOverlay()
                        }
                    }
                })
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
                            if addOverlay {
                                print("\n NEW ACTIVITY :\(AddActivityOverlay().newActivity)\n")
                            }
                            addOverlay.toggle()
                        }, label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.accent)
                                .padding(.trailing, 10)
                        })
                    }
                }
            }
        }
    }
}

#Preview {
    ActivitiesView()
        .environmentObject(PhysicalActivityViewModel())
        .environmentObject(TypeActivityViewModel())
}

struct AddActivityOverlay : View {
    @EnvironmentObject var typeActivityViewModel : TypeActivityViewModel
    @State var newActivity: PhysicalActivity = PhysicalActivity(durationActivity: 0.0, caloriesBurned: 0.0, dateActivity: Date(), typeActivity: TypeActivity(id: UUID(), nameTypeActivity: "Aucun"), user: PartialUserUpdate())
    var body: some View {
        VStack {
            Text("Ajouter une activité")
                .font(
                    .system(size: 30)
                .weight(.bold)
                )
                .foregroundColor(.white)
                .padding(.bottom, 10)
            HStack {
                Text("Type d’Activité")
                    .font(.system(size: 17)
                    .weight(.bold))
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                Spacer()
                Menu {
                    ForEach(typeActivityViewModel.typeActivities.indices, id: \.self) { index in
                        Button(action: {
                            newActivity.typeActivity.nameTypeActivity = typeActivityViewModel.typeActivities[index].nameTypeActivity
                        }) {
                            Text(typeActivityViewModel.typeActivities[index].nameTypeActivity ?? "Aucun")
                                .font(.system(size: 16, weight: .regular)) // Personnalisation
                                .foregroundColor(.grey) // Couleur personnalisée
                        }
                    }
                } label: {
                    Text(newActivity.typeActivity.nameTypeActivity ?? "Aucun")
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
                .accentColor(.grey)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 135, alignment: .trailing)
                .background(.white)
                .cornerRadius(25)
                .padding(.vertical, 13)
                Spacer()

            }
            .padding(.bottom, -15)
            
            HStack(spacing: 4) {
                Text("Durée d'Activité")
                    .font(.system(size: 17)
                        .weight(.bold))
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        newActivity.durationActivity -= 1
                    }, label: {
                        Image(systemName: "minus")
                            .bold()
                    })
                    
                    TextField(value: $newActivity.durationActivity, format: .number, label: {
                        Text("\(newActivity.durationActivity,  specifier: "%.1f")")
                    })
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .frame(width: 30, alignment: .center)
                    
                    Button(action: {
                        newActivity.durationActivity += 1
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
                
                Text("min")
                    .font(.system(size: 12))
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.bottom, -14)
            
            HStack(spacing: 4) {
                Text("Calories Brûlées")
                    .font(.system(size: 17)
                        .weight(.bold))
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        newActivity.caloriesBurned! -= 1
                    }, label: {
                        Image(systemName: "minus")
                            .bold()
                    })
                    
                    TextField(value: $newActivity.caloriesBurned, format: .number, label: {
                        Text("\(newActivity.caloriesBurned ?? 0.0,  specifier: "%.1f")")
                    })
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .frame(width: 30, alignment: .center)
                    
                    Button(action: {
                        newActivity.caloriesBurned! += 1
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
                
                Text("cal")
                    .font(.system(size: 12))
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
            }
            
        }
        .padding()
        .background{
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 402)
                .background(Color(red: 0.53, green: 0.42, blue: 0.34))
                .cornerRadius(49)
        }
    }
}
