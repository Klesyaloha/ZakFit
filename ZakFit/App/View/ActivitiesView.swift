//
//  ActivitiesView.swift
//  ZakFit
//
//  Created by Klesya on 04/01/2025.
//

import SwiftUI

struct ActivitiesView: View {
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
                    Text("Vendredi 4 Janvier 2025")
                        .frame(maxWidth: .infinity ,alignment: .leading)
                        .padding(.leading, 16)
                        .foregroundStyle(.accent)
                        .font(.system(size: 14, weight: .bold))
                    HStack {
                        Spacer()
                        Text("Course")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Text("30min")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Text("-257 cal")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.grey)
                        Spacer()
                    }
                    .background {
                        Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 351, height: 43)
                        .background(Color(red: 0.9, green: 0.6, blue: 0.36).opacity(0.39))

                        .cornerRadius(12)
                    }
                    .padding(.top)
                    .padding(.bottom, 8)
                    
                    HStack {
                        Spacer()
                        Text("Course")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Text("30min")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Text("-257 cal")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.grey)
                        Spacer()
                    }
                    .background {
                        Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 351, height: 43)
                        .background(Color(red: 0.9, green: 0.6, blue: 0.36).opacity(0.39))

                        .cornerRadius(12)
                    }
                    .padding()
                    
                    Spacer()
                    
                    AddActivityOverlay()
                }
                .navigationTitle("Mes Activités")
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
                            
                        }, label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.red)
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
}

struct AddActivityOverlay : View {
    var body: some View {
        Rectangle()
        .foregroundColor(.clear)
        .frame(width: 402, height: 273)
        .background(Color(red: 0.53, green: 0.42, blue: 0.34))
        .cornerRadius(49)
    }
}
