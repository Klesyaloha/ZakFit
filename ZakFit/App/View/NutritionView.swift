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
    @EnvironmentObject var compositionViewModel : CompositionViewModel
    
    @State var newMeal: Meal = Meal(nameMeal: "", typeOfMeal: "", quantityMeal: 1.0, dateMeal: Date(), caloriesByMeal: 0.0, user: PartialUserUpdate())
    @State var newComposition: PartialComposition = PartialComposition(id: UUID(), foodId: UUID(), mealId: UUID(), quantity: 0.0)
    @State var foodsTab: [Food] = []
    
    @State var text: String = ""
    @State var addOverlay: Bool = false
    @State var addDeleteButton : Bool = false
    
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
                    VStack(spacing: 3) {
                        
                        ForEach(Dictionary(grouping: mealViewModel.meals, by: { $0.meal.formattedDate }).keys.sorted { lhs, rhs in
                            let formatter = DateFormatter()
                            formatter.dateFormat = "EEEE d MMMM yyyy" // Format attendu pour `formattedDate`
                            formatter.locale = Locale(identifier: "fr_FR") // Définir la locale en français
                            
                            guard let lhsDate = formatter.date(from: lhs),
                                  let rhsDate = formatter.date(from: rhs) else {
                                return lhs < rhs // Si la conversion échoue, tri basique (descendant)
                            }
                            return lhsDate > rhsDate // Tri décroissant
                        }, id: \.self) { date in
                            VStack(spacing: 3) {
                                // Afficher la date (une seule fois pour chaque groupe)
                                Text(date)
                                    .frame(maxWidth: .infinity ,alignment: .leading)
                                    .padding(.leading, 16)
                                    .foregroundStyle(.accent)
                                    .font(.system(size: 14, weight: .bold))
                                
                                // Afficher les activités pour cette date
                                ForEach(mealViewModel.meals.filter { $0.meal.formattedDate == date }) { mealWithFood in
                                    Button(action: {
                                        if addDeleteButton && addOverlay {
                                            Task {
                                                await compositionViewModel.fetchCompositions(for: newMeal.id)
                                                
                                                for food in foodsTab {
                                                    let composition = PartialComposition(
                                                        id: UUID(),
                                                        foodId: food.id,
                                                        mealId: newMeal.id,
                                                        quantity: food.quantityFood // Ajoutez la logique pour définir la quantité
                                                    )
                                                    if let existingComposition = compositionViewModel.compositions.first(where: { $0.food.id == food.id && $0.meal.id == newMeal.id }) {
                                                        print("🔍 Composition trouvée: \(existingComposition)")
                                                    } else {
                                                        print("❌ Aucune composition trouvée.")
                                                        await compositionViewModel.addComposition(composition)
                                                    }
                                                    
                                                }
                                                await mealViewModel.updateMeal(newMeal)
                                                await mealViewModel.fetchMealsWithFood()
                                            }
                                            addDeleteButton = false
                                        } else if !addOverlay && !addDeleteButton {
                                            newMeal = mealWithFood.meal
                                            foodsTab = mealWithFood.foods
                                            self.text = "Modifier le repas"
                                            addDeleteButton = true
                                        }
                                        addOverlay.toggle()
                                    }, label: {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Text(mealWithFood.meal.typeOfMeal)
                                                    .font(.system(size: 17, weight: .semibold))
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
                                                        .foregroundStyle(.black)
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
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(mealWithFood.meal.id == newMeal.id && addOverlay && addDeleteButton ? Color.accent : Color.clear, lineWidth: 2.5) // Couleur et épaisseur de la bordure
                                                )
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
                if addOverlay {
                    VStack {
                        Spacer()
                        if addDeleteButton {
                            Button(action:{
                                Task {
                                    await mealViewModel.deleteMeal(newMeal.id)
                                    await foodViewModel.fetchFoods()
                                    await mealViewModel.fetchMealsWithFood()
                                }
                                addOverlay = false
                                addDeleteButton = false
                            }, label: {
                                Text("Supprimer")
                                    .padding()
                                    .fontWeight(.black)
                                    .foregroundStyle(.white)
                                    .background(.accent)
                                    .cornerRadius(12)
                            })
                        }
                        AddMealOverlay(text: text, newMeal: $newMeal, newComposition: $newComposition, foodsTab: $foodsTab)
                    }
                }
            }
            .onAppear {
                Task {
                    await foodViewModel.fetchFoods()
                    await mealViewModel.fetchMealsWithFood()
                }
            }
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
                        if addOverlay && !addDeleteButton && !newMeal.nameMeal.isEmpty {
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
                            addOverlay = false
                        } else if !addOverlay && !addDeleteButton {
                            newMeal = Meal(nameMeal: "", typeOfMeal: "", quantityMeal: 1.0, dateMeal: Date(), caloriesByMeal: 0.0, user: PartialUserUpdate())
                            foodsTab.removeAll()
                            text = "Ajouter un repas"
                            addOverlay = true
                        }
                    }, label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.accent)
                            .padding(.trailing, 10)
                    })
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
        .environmentObject(CompositionViewModel())
}

struct AddMealOverlay : View {
    @EnvironmentObject var foodViewModel : FoodViewModel
    @EnvironmentObject var mealViewModel : MealViewModel
    @EnvironmentObject var compositionViewModel : CompositionViewModel
    @State var text: String = ""
    @Binding var newMeal: Meal
    @Binding var newComposition: PartialComposition
    @Binding var foodsTab: [Food]
    @State var showAlert: Bool = false
    @State var textAlert : String = ""
    
    let typesOfMeals = [
        "Petit-déjeuner",
        "Déjeuner",
        "Collation",
        "Dîner"
    ]
    
    var body: some View {
        VStack(spacing: 7) {
            Text(text)
                .font(
                    .system(size: 30)
                .weight(.bold)
                )
                .foregroundColor(.white)
                .padding(.bottom, 10)
            
            TextField("Nom du repas", text: $newMeal.nameMeal)
                .font(.system(size: 17) .weight(.bold))
                .foregroundStyle(.grey)
                .padding()
                .frame(height: 32)
                .background(.white)
                .cornerRadius(25)
                .padding(.horizontal, 20)
            
            HStack(spacing: 20) {
                Text("Type de repas")
                    .font(.system(size: 17) .weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Menu {
                    ForEach(typesOfMeals.indices, id: \.self) { index in
                        Button(action: {
                            newMeal.typeOfMeal = typesOfMeals[index]
                        }) {
                            Text(typesOfMeals[index])
                        }
                    }
                } label: {
                    HStack(spacing: 0) {
                        Text(newMeal.typeOfMeal.isEmpty ? "Choisir..." : newMeal.typeOfMeal)
                            .frame(maxWidth: .infinity)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .padding(.trailing)
                            .foregroundStyle(.grey)
                        
                    }
                    
                }
                .frame(height: 32)
                .accentColor(.grey)
                .font(.system(size: 15, weight: .semibold))
                .background(.white)
                .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            
            HStack {
                Text("Aliments")
                    .font(.system(size: 17) .weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Menu {
                    ForEach(foodViewModel.foods.indices, id: \.self) { index in
                        Button(action: {
                            if !foodsTab.contains(where: { $0.id == foodViewModel.foods[index].id }) {
                                foodsTab.append(foodViewModel.foods[index])
                                newMeal.caloriesByMeal = foodsTab.map({$0.caloriesByFood}).reduce(0, +)
                            } else {
                                self.textAlert = "L'aliment ajouté est déja présent, veuillez ajuster la quantité."
                                showAlert = true
                            }
                        }) {
                            Text(foodViewModel.foods[index].nameFood)
                            Spacer()
                            if foodsTab.contains(where: { $0.id == foodViewModel.foods[index].id }) {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 0) {
                        Text(foodsTab.last?.nameFood ?? "Choisir")
                            .frame(height: 32)
                            .padding(.horizontal, 30)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .padding(.trailing)
                            .foregroundStyle(.grey)
                    }
                    
                }
                .accentColor(.grey)
                .font(.system(size: 15, weight: .semibold))
                .background(.white)
                .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 5)
            
            VStack(spacing: 0) {
                ForEach($foodsTab.indices, id: \.self) { index in
                    Divider()
                        .background(Color.white)
                        .frame(width: 300)
                    
                    HStack {
                        Text("• \(foodsTab[index].nameFood)")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .padding(.leading ,30)
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                foodsTab[index].quantityFood -= 1
                            }, label: {
                                Image(systemName: "minus")
                                    .bold()
                            })
                            
                            TextField(value: $foodsTab[index].quantityFood, format: .number, label: {
                                Text("\(foodsTab[index].quantityFood,  specifier: "%.1f")")
                            })
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .frame(width: 40, alignment: .center)
                            
                            Button(action: {
                                foodsTab[index].quantityFood += 1
                            }, label: {
                                Image(systemName: "plus")
                                    .bold()
                            })
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .background{
                            Rectangle()
                                .frame(height: 30)
                                .foregroundStyle(.grey)
                                .opacity(0.5)
                                .cornerRadius(24)
                        }
                        .padding(.trailing, 20)
                        
                        Button(action: {
                            Task {
                                await compositionViewModel.fetchCompositions(for: newMeal.id)
                                
                                if index >= 0 && index < foodsTab.count {
                                    let foodToCheck = foodsTab[index]
                                    
                                    if let existingComposition = compositionViewModel.compositions.first(where: { $0.food.id == foodToCheck.id && $0.meal.id == newMeal.id }) {
                                        await compositionViewModel.deleteComposition(existingComposition.id)
                                    }
                                    
                                    DispatchQueue.main.async {
                                        if index >= 0 && index < foodsTab.count {
                                            newMeal.caloriesByMeal -= foodToCheck.caloriesByFood
                                            foodsTab.remove(at: index)
                                        }
                                    }
                                }
                            }
                        }, label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        })
                        .padding(.trailing ,30)
                        
                    }
                    
//                    if foodsTab.last.nameFood == foodsTab[index].nameFood {
//                        Divider()
//                            .background(Color.white)
//                            .frame(width: 300)
//                    }
                }
            }
            
            HStack {
                Text("Quantité")
                    .font(.system(size: 17) .weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        newMeal.quantityMeal -= 0.5
                    }, label: {
                        Image(systemName: "minus")
                            .bold()
                    })
                    .padding(.leading, 16)
                    
                    TextField(value: $newMeal.quantityMeal, format: .number, label: {
                        Text("\(newMeal.quantityMeal,  specifier: "%.1f")")
                    })
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .frame(width: 40, alignment: .center)
                    
                    Button(action: {
                        newMeal.quantityMeal += 0.5
                    }, label: {
                        Image(systemName: "plus")
                            .bold()
                    })
                    .padding(.trailing, 16)
                }
                .foregroundStyle(.grey)
                .background{
                    Rectangle()
                        .frame(height: 30)
                        .foregroundStyle(.white)
                        .cornerRadius(24)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            HStack {
                Text("Calories")
                    .font(.system(size: 17) .weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        newMeal.caloriesByMeal -= 1
                    }, label: {
                        Image(systemName: "minus")
                            .bold()
                    })
                    .padding(.leading, 16)
                    
                    TextField(value: $newMeal.caloriesByMeal, format: .number, label: {
                        Text("\(newMeal.caloriesByMeal,  specifier: "%.1f")")
                    })
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .frame(width: 40, alignment: .center)
                    
                    Button(action: {
                        newMeal.caloriesByMeal += 0.5
                    }, label: {
                        Image(systemName: "plus")
                            .bold()
                    })
                    .padding(.trailing, 16)
                }
                .foregroundStyle(.grey)
                .background{
                    Rectangle()
                        .frame(height: 30)
                        .foregroundStyle(.white)
                        .cornerRadius(24)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            HStack {
                Text("Date")
                    .font(.system(size: 17)
                        .weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                DatePicker(selection: $newMeal.dateMeal, label: {
                    Text("Date")
                })
                .padding(.horizontal)
                .colorScheme(.dark)
                .labelsHidden()
            }
            .padding(.top, -13)
            .padding(.horizontal, 20)
            .padding(.bottom, 5)
        }
        .padding()
//        .onAppear{
//            Task {
//                await compositionViewModel.fetchCompositions(for: newMeal.id)
//            }
//        }
        .background{
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 402)
                .background(Color(red: 0.53, green: 0.42, blue: 0.34))
                .cornerRadius(49)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Erreur"),
                message: Text(textAlert),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
