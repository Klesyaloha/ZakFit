//
//  DashboardView.swift
//  ZakFit
//
//  Created by Klesya on 06/01/2025.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var userViewModel : UserViewModel
    @EnvironmentObject var mealViewModel: MealViewModel
    @EnvironmentObject var foodViewModel: FoodViewModel
    @EnvironmentObject var physicalActivityViewModel : PhysicalActivityViewModel
    @EnvironmentObject var typeActivityViewModel : TypeActivityViewModel
    
    let progress: CGFloat = 0.5
    let totalCalories: CGFloat = 2000  // Objectif de calories
    
    // Pourcentages de l'objectif calorique pour chaque macronutriment
    let proteinPercentage: CGFloat = 0.15 // 15% des calories
    let carbPercentage: CGFloat = 0.50    // 50% des calories
    let fatPercentage: CGFloat = 0.35     // 35% des calories
    
    // Calcul des calories consommées pour chaque macronutriment
    var caloriesConsumed: CGFloat {
        return totalCalories * progress
    }
    
    var proteinCalories: CGFloat {
        return caloriesConsumed * proteinPercentage
    }
    
    var carbCalories: CGFloat {
        return caloriesConsumed * carbPercentage
    }
    
    var fatCalories: CGFloat {
        return caloriesConsumed * fatPercentage
    }
    
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
                
                ScrollView {
                    HStack {
                        Text("Bonjour \(userViewModel.currentUser.nameUser)!")
                            .font(.system(size: 38, weight: .regular))
                            .foregroundColor(.accent)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.leading, 16)
                            .padding(.bottom, 45)
                        Button(action: {
                            
                        }, label: {
                            VStack(spacing: 3) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white)
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 17))
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 30)
                            .padding(.all, 7)
                            .background(.accent.opacity(0.7))
                            .cornerRadius(10)
                        })
                        
                        Button(action: {
                            
                        }, label: {
                            VStack(spacing: 3) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white)
                                Image(systemName: "figure.run")
                                    .font(.system(size: 17))
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 25)
                            .padding(.all, 7)
                            .background(.grey.opacity(0.7))
                            .cornerRadius(10)
                            .padding(.trailing,10)
                        })
                    }
                        
                    VStack {
                        HStack {
                            ZStack {
                                // Background circle
                                Circle()
                                    .stroke(lineWidth: 60)
                                    .frame(width: 188)
                                    .opacity(0.5)
                                    .foregroundColor(Color.grey)
                                
                                // Progress circle with segmented colors for each macronutrient
                                ZStack {
                                    // Proteins (blue)
                                    Circle()
                                        .trim(from: 0, to: proteinPercentage * progress)
                                        .stroke(style: StrokeStyle(lineWidth: 60, lineCap: .butt, lineJoin: .round))
                                        .foregroundColor(Color.blue)
                                        .rotationEffect(Angle(degrees: -90)) // Start at 12h
                                    
                                    // Carbs (orange)
                                    Circle()
                                        .trim(from: proteinPercentage * progress, to: (proteinPercentage + carbPercentage) * progress)
                                        .stroke(style: StrokeStyle(lineWidth: 60, lineCap: .butt, lineJoin: .round))
                                        .foregroundColor(Color.accent)
                                        .rotationEffect(Angle(degrees: -90)) // Start at 12h
                                    
                                    // Fats (red)
                                    Circle()
                                        .trim(from: (proteinPercentage + carbPercentage) * progress, to: (proteinPercentage + carbPercentage + fatPercentage) * progress)
                                        .stroke(style: StrokeStyle(lineWidth: 60, lineCap: .butt, lineJoin: .round))
                                        .foregroundColor(Color.red)
                                        .rotationEffect(Angle(degrees: -90)) // Start at 12h
                                }
                                
                                // Text showing the number of calories consumed
                                Text(String(format: "%.0f cal", caloriesConsumed))
                                    .font(.system(size: 23))
                                    .bold()
                                    .foregroundColor(.black)
                            }
                            .frame(width: 188)
                        }
                        
                        // Displaying the breakdown of calories
                        VStack(spacing: 3) {
                            HStack {
                                Text("Protéines")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.blue)
                                Spacer()
                                Text(String(format: "%.0f cal", proteinCalories))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            HStack {
                                Text("Glucides")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.accent)
                                Spacer()
                                Text(String(format: "%.0f cal", carbCalories))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.accent)
                            }
                            HStack {
                                Text("Lipides")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.red)
                                Spacer()
                                Text(String(format: "%.0f cal", fatCalories))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        
                        Text("Aujourd'hui")
                            .font(.system( size: 22, weight: .bold))
                            .foregroundColor(.grey)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                        
                        VStack {
                            HStack(spacing: 2){
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.accent)
                                    .padding(.leading, 25)
                                
                                Text("Repas")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if mealViewModel.meals.filter({ $0.meal.dateMeal == Date()}).isEmpty {
                                Text("Aucun repas enregistré")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.grey)
                                    .padding()
                            }
                            
                            ForEach(mealViewModel.meals.filter({ $0.meal.dateMeal == Date()}), id: \.id) { mealWithFood in
                                    HStack {
                                        Spacer()
                                        Text(mealWithFood.meal.typeOfMeal)
                                            .font(.system(size: 17, weight: .semibold))
                                            .lineLimit(1)
                                            .foregroundStyle(.white)
                                            .frame(width: 83, alignment: .center)
                                        
                                        Spacer()
                                        
                                        Text(mealWithFood.meal.nameMeal)
                                            .font(.system(size: 15))
                                            .foregroundStyle(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        Spacer()
                                        
                                        Text("+\(String(format: "%0.f", mealWithFood.meal.caloriesByMeal))kcal")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(.grey)
                                            .frame(width: 83, alignment: .center)
                                        Spacer()
                                    }
                                    .padding(.top, 10)
                                
                                Rectangle()
                                  .foregroundColor(.clear)
                                  .frame(width: 351, height: 1)
                                  .background(.white.opacity(0.13))
                            }
                        }
                        .padding()
                        .background{
                            Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 351)
                            .background(Color(red: 0.9, green: 0.6, blue: 0.36).opacity(0.39))

                            .cornerRadius(12)
                        }
                        
                        VStack {
                            HStack(spacing: 2){
                                Image(systemName: "figure.run")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.accent)
                                    .padding(.leading, 25)
                                
                                Text("Activités")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if physicalActivityViewModel.activities.filter({ $0.dateActivity == Date()}).isEmpty {
                                Text("Aucune activité enregistré")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.grey)
                                    .padding()
                            }
                            
                            ForEach(physicalActivityViewModel.activities.filter({ $0.dateActivity == Date()}), id: \.id) { activity in
                                    HStack {
                                        Spacer()
                                        Text(activity.typeActivity.nameTypeActivity ?? "Inconnu")
                                            .font(.system(size: 17, weight: .semibold))
                                            .lineLimit(1)
                                            .foregroundStyle(.white)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        
                                        Spacer()
                                            .frame(width: 30, alignment: .center)
                                        
                                        Text("\(Int(activity.durationActivity))min")
                                            .font(.system(size: 15))
                                            .foregroundStyle(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        Spacer()
                                            .frame(width: 30, alignment: .center)
                                        
                                        Text("-\(Int(activity.caloriesBurned ?? 0))cal")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(.grey)
                                            .frame(width: 83, alignment: .center)
                                        Spacer()
                                    }
                                    .padding()
                                
                                Rectangle()
                                  .foregroundColor(.clear)
                                  .frame(width: 351, height: 1)
                                  .background(.white.opacity(0.13))
                            }
                        }
                        .padding()
                        .background{
                            Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 351)
                            .background(Color(red: 0.9, green: 0.6, blue: 0.36).opacity(0.39))

                            .cornerRadius(12)
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .onAppear(perform: {
                Task {
                    await userViewModel.login()
                    await mealViewModel.fetchMealsWithFood()
                    await physicalActivityViewModel.fetchActivities()
                    await typeActivityViewModel.fetchTypeActivities()
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
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(UserViewModel())
        .environmentObject(MealViewModel())
        .environmentObject(FoodViewModel())
        .environmentObject(PhysicalActivityViewModel())
        .environmentObject(TypeActivityViewModel())
}

