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
    @EnvironmentObject var compositionViewModel : CompositionViewModel
    @EnvironmentObject var physicalActivityViewModel : PhysicalActivityViewModel
    @EnvironmentObject var typeActivityViewModel : TypeActivityViewModel
    
    let progress: CGFloat = 0.5
    let totalCalories: CGFloat = 2000  // Objectif de calories
    
    // Calcul des calories consommées pour les repas aujourd'hui
    var caloriesConsumed: CGFloat {
        let mealsToday = mealViewModel.meals.filter {
            Calendar.current.isDate($0.meal.dateMeal, inSameDayAs: Date())
        }
        return mealsToday.reduce(0) { $0 + CGFloat($1.meal.caloriesByMeal) }
    }
    
    // Calcul des calories brûlées par les activités aujourd'hui
    var caloriesBurned: CGFloat {
        let activitiesToday = physicalActivityViewModel.activities.filter {
            Calendar.current.isDate($0.dateActivity, inSameDayAs: Date())
        }
        return activitiesToday.reduce(0) { $0 + CGFloat($1.caloriesBurned ?? 0) }
    }
    
    // Calories nettes consommées (calories des repas moins calories brûlées)
    var netCalories: CGFloat {
        return caloriesConsumed - caloriesBurned
    }
    
    // Calcul des totaux des macronutriments pour aujourd'hui en fonction des aliments
    var totalProteins: CGFloat {
        let mealsToday = mealViewModel.meals.filter {
            Calendar.current.isDate($0.meal.dateMeal, inSameDayAs: Date())
        }
        // Additionner les macronutriments de chaque aliment consommé aujourd'hui
        return mealsToday.reduce(0) { total, meal in
            total + meal.foods.reduce(0) { $0 + CGFloat($1.proteins) }
        }
    }
    
    var totalCarbs: CGFloat {
        let mealsToday = mealViewModel.meals.filter {
            Calendar.current.isDate($0.meal.dateMeal, inSameDayAs: Date())
        }
        // Additionner les glucides de chaque aliment consommé aujourd'hui
        return mealsToday.reduce(0) { total, meal in
            total + meal.foods.reduce(0) { $0 + CGFloat($1.carbs) }
        }
    }
    
    var totalFats: CGFloat {
        let mealsToday = mealViewModel.meals.filter {
            Calendar.current.isDate($0.meal.dateMeal, inSameDayAs: Date())
        }
        // Additionner les lipides de chaque aliment consommé aujourd'hui
        return mealsToday.reduce(0) { total, meal in
            total + meal.foods.reduce(0) { $0 + CGFloat($1.fats) }
        }
    }
    @State var text : String = ""
    @State var addOverlayActivity: Bool = false
    @State var newActivity = PhysicalActivity(durationActivity: 0.0, caloriesBurned: 0.0, dateActivity: Date(), typeActivity: TypeActivity(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")! , nameTypeActivity: "Aucun"), user: PartialUserUpdate())
    
    @State var addOverlayFood: Bool = false
    @State var newMeal: Meal = Meal(nameMeal: "", typeOfMeal: "", quantityMeal: 1.0, dateMeal: Date(), caloriesByMeal: 100.0, user: PartialUserUpdate())
    @State var newComposition: PartialComposition = PartialComposition(id: UUID(), foodId: UUID(), mealId: UUID(), quantity: 0.0)
    @State var foodsTab: [Food] = []
    
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
                            if addOverlayFood && !newMeal.nameMeal.isEmpty {
                                Task {
                                    // Ajouter d'abord le repas
                                    await mealViewModel.addMeal(newMeal)
                                    
                                    await mealViewModel.fetchMeals()
                                    
                                    // Vérifier que le repas est dans la liste et obtenir son ID
                                    guard let meal = mealViewModel.mealsOnly.first(where: { $0.nameMeal == newMeal.nameMeal }) else {
                                        print("Erreur : Le repas n'a pas pu être trouvé.")
                                        return
                                    }
                                    
                                    let mealId = meal.id
                                    
                                    // Ajouter les compositions maintenant que le repas est ajouté
                                    for food in foodsTab {
                                        newComposition = PartialComposition(
                                            id: UUID(),
                                            foodId: food.id,
                                            mealId: mealId, // Utiliser l'ID du repas ajouté
                                            quantity: food.quantityFood
                                        )
                                        await compositionViewModel.addComposition(newComposition)
                                    }
                                    
                                    // Rechercher les repas avec leurs compositions après l'ajout
                                    await mealViewModel.fetchMealsWithFood()
                                }
                                
                                // Masquer l'overlay une fois l'ajout terminé
                                addOverlayFood = false
                            } else if !addOverlayFood {
                                newMeal = Meal(nameMeal: "", typeOfMeal: "", quantityMeal: 1.0, dateMeal: Date(), caloriesByMeal: 100.0, user: PartialUserUpdate())
                                foodsTab.removeAll()
                                text = "Ajouter un repas"
                                addOverlayFood = true
                            }
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
                            if addOverlayActivity {
                                Task {
                                    await physicalActivityViewModel.addActivity(newActivity)
                                    await physicalActivityViewModel.fetchActivities()
                                }
                                addOverlayActivity = false
                        } else if !addOverlayActivity {
                                newActivity = PhysicalActivity(durationActivity: 0.0, caloriesBurned: 0.0, dateActivity: Date(), typeActivity: TypeActivity(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")! , nameTypeActivity: "Aucun"), user: PartialUserUpdate())
                                text = "Ajouter une activité"
                            addOverlayActivity = true
                            }
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
                            VStack {
                                Text(String(format: "%.0f cal", totalProteins))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.blue)
                                Text(String(format: "%.0f cal", totalCarbs))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.accent)
                                Text(String(format: "%.0f cal", totalFats))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            .padding(.leading, 16)
                            
                            Spacer()
                            
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
                                        .trim(from: 0, to: totalProteins/caloriesConsumed)
                                        .stroke(style: StrokeStyle(lineWidth: 60, lineCap: .butt, lineJoin: .round))
                                        .foregroundColor(Color.blue)
                                        .rotationEffect(Angle(degrees: -90)) // Start at 12h
                                    
                                    // Carbs (orange)
                                    Circle()
                                        .trim(from: totalProteins/caloriesConsumed * progress, to: (totalProteins/caloriesConsumed + totalCarbs/caloriesConsumed) * progress)
                                        .stroke(style: StrokeStyle(lineWidth: 60, lineCap: .butt, lineJoin: .round))
                                        .foregroundColor(Color.accent)
                                        .rotationEffect(Angle(degrees: -90)) // Start at 12h
                                    
                                    // Fats (red)
                                    Circle()
                                        .trim(from: (totalProteins/caloriesConsumed + totalCarbs/caloriesConsumed) * progress, to: (totalProteins/caloriesConsumed + totalCarbs/caloriesConsumed + totalFats/caloriesConsumed) * progress)
                                        .stroke(style: StrokeStyle(lineWidth: 60, lineCap: .butt, lineJoin: .round))
                                        .foregroundColor(Color.red)
                                        .rotationEffect(Angle(degrees: -90)) // Start at 12h
                                }
                                
                                // Text showing the number of calories consumed
                                Text(String(format: "%.0f kcal", netCalories))
                                    .font(.system(size: 23))
                                    .bold()
                                    .foregroundColor(.black)
                            }
                            .frame(width: 188)
                            
                            Spacer()
                            
                            VStack {
                                Text("Protéines")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.blue)
                                Text("Glucides")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.accent)
                                Text("Lipides")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.red)
                            }
                            .padding(.trailing, 16)
                        }
                        .padding(.bottom)
                        
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
                            
                            if !(mealViewModel.meals.contains(where: {
                                Calendar.current.isDate($0.meal.dateMeal, inSameDayAs: Date())
                            })) {
                                Text("Aucun repas enregistré")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.grey)
                                    .padding()
                            }
                            
                            let meals = mealViewModel.meals.filter { mealWithFood in
                                Calendar.current.isDate(mealWithFood.meal.dateMeal, inSameDayAs: Date())
                            }

                            ForEach(meals.indices, id: \.self) { index in
                                let mealWithFood = meals[index]
                                    HStack {
                                        Spacer()
                                        Text(mealWithFood.meal.typeOfMeal)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(.white)
                                        
                                        Spacer()
                                        
                                        Text(mealWithFood.meal.nameMeal)
                                            .font(.system(size: 15))
                                            .foregroundStyle(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        Spacer()
                                        
                                        Text("+\(String(format: "%0.f", mealWithFood.meal.caloriesByMeal))kcal")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(.grey)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                
                                if index != meals.count - 1 {
                                    Divider()
                                        .background(Color.white)
                                        .frame(width: 300)
                                }
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
                            
                            if !(physicalActivityViewModel.activities.contains(where: {
                                Calendar.current.isDate($0.dateActivity, inSameDayAs: Date())
                            })) {
                                Text("Aucune activité enregistré")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.grey)
                                    .padding()
                            }
                            
                            let activities = physicalActivityViewModel.activities.filter { activity in
                                Calendar.current.isDate(activity.dateActivity, inSameDayAs: Date())
                            }
                            
                            ForEach(activities.indices, id: \.self) { index in
                                let activity = activities[index]
                                
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
                                        
                                        Text("-\(Int(activity.caloriesBurned ?? 0))kcal")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(.grey)
                                            .frame(width: 83, alignment: .center)
                                        Spacer()
                                    }
                                    .padding()
                                
                                if index != activities.count - 1 { // Ajoute un Divider sauf pour le dernier élément
                                    Divider()
                                        .background(Color.white)
                                        .frame(width: 300)
                                }
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
                    await foodViewModel.fetchFoods()
                }
            })
            .overlay(content: {
                if addOverlayActivity {
                    VStack {
                        Spacer()
                        AddActivityOverlay(text: text,newActivity: $newActivity)
                    }
                }
                if addOverlayFood {
                    VStack {
                        Spacer()
                        AddMealOverlay(text: text, newMeal: $newMeal, newComposition: $newComposition, foodsTab: $foodsTab)
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
        .environmentObject(CompositionViewModel())
}

