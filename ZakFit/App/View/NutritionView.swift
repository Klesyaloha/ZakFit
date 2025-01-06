//
//  NutritionView.swift
//  ZakFit
//
//  Created by Klesya on 06/01/2025.
//

import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var mealViewModel: MealViewModel
    @EnvironmentObject var foodViewModel: FoodViewModel
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
                    ForEach(mealViewModel.meals, id: \.id) { mealWithFood in
                        VStack {
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
                            ForEach(mealWithFood.foods) { food in
                                VStack(alignment: .leading) {
                                    Spacer()
                                    Text(food.nameFood)
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    HStack {
                                        Text("Calories:\n\(String(format: "%0.f", food.caloriesByFood)) kcal")
                                        Text("Protéines:\n\(String(format: "%0.f", food.proteins)) g")
                                        Text("Glucides:\n\(String(format: "%0.f", food.carbs)) g")
                                        Text("Graisses:\n\(String(format: "%0.f", food.fats)) g")
                                    }
                                    .multilineTextAlignment(.center)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 351)
                                .background(Color(red: 0.9, green: 0.6, blue: 0.36).opacity(0.39))
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    
                    HStack {
                        Spacer()
                        Text("Test4")
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(1)
                            .foregroundStyle(.white)
                            .frame(width: 83, alignment: .center)
                        
                        Spacer()
                        
                        Text("Test2")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Text("Test3")
                            .font(.system(size: 14, weight: .semibold))
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
                    
                    //                NavigationView {
                    //                    List(mealViewModel.meals) { mealWithFood in
                    //                        Section(header: Text(mealWithFood.meal.nameMeal)) {
                    //                            Text("Type de repas: \(mealWithFood.meal.typeOfMeal)")
                    //                            Text("Calories: \(mealWithFood.meal.caloriesByMeal) kcal")
                    //
                    //                            ForEach(mealWithFood.foods) { food in
                    //                                VStack(alignment: .leading) {
                    //                                    Text(food.nameFood)
                    //                                        .font(.headline)
                    //                                    HStack {
                    //                                        Text("Calories: \(food.caloriesByFood) kcal")
                    //                                        Text("Protéines: \(food.proteins) g")
                    //                                        Text("Glucides: \(food.carbs) g")
                    //                                        Text("Graisses: \(food.fats) g")
                    //                                    }
                    //                                    .font(.subheadline)
                    //                                    .foregroundColor(.gray)
                    //                                }
                    //                            }
                    //                        }
                    //                    }
                    //                    .navigationBarTitle("Mes Repas")
                    //                }
                }
            }
            .onAppear {
                Task {
                    await mealViewModel.fetchMealsWithFood()
                }
            }
            .navigationTitle("Mes Repas")
        }
    }
}

#Preview {
    NutritionView()
        .environmentObject(MealViewModel())
        .environmentObject(FoodViewModel())
}
