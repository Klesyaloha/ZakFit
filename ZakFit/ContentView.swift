//
//  ContentView.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import SwiftUI

struct PhysicalActivityViewTest: View {
    @State var newActivity = PhysicalActivity(durationActivity: 0.0, caloriesBurned: 0.0, dateActivity: Date(), typeActivity: TypeActivity(id: UUID(), nameTypeActivity: "Aucun"), user: PartialUserUpdate())
    @State private var showAddActivityOverlay = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Activité: \(newActivity.typeActivity.nameTypeActivity ?? "")")
                    .font(.largeTitle)
                    .padding()
                
                Text("Durée: \(newActivity.durationActivity) min")
                Text("Calories brûlées: \(Int(newActivity.caloriesBurned ?? 0)) cal")
                
                Button("Modifier l'Activité") {
                    showAddActivityOverlay.toggle()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Ma Journée d'Activité")
            .overlay(
                Group {
                    if showAddActivityOverlay {
                        AddActivityOverlayTest(newActivity: $newActivity)
                            .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
                    }
                }
            )
        }
    }
}

struct AddActivityOverlayTest: View {
    @Binding var newActivity: PhysicalActivity

    var body: some View {
        VStack {
            Text("Modifier l'Activité")
                .font(.title)
                .padding()

            VStack {
                Text("Durée de l'activité")
                TextField("Durée", value: $newActivity.durationActivity, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("Calories brûlées")
                TextField("Calories", value: $newActivity.caloriesBurned, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("Nom de l'activité")
                TextField("Nom", text: Binding(
                    get: { newActivity.typeActivity.nameTypeActivity ?? "" },  // Fournir une valeur par défaut si nil
                    set: { newActivity.typeActivity.nameTypeActivity = $0 }   // Mettre à jour avec la valeur saisie
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            }
            .padding()

            Button("Sauvegarder") {
                // Fermeture de l'overlay et sauvegarde des modifications
                // Aucune action spécifique ici, car la donnée est bindée
                withAnimation {
                    newActivity.dateActivity = Date()  // Mettre à jour la date si nécessaire
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .frame(maxWidth: 400)
    }
}

struct PhysicalActivityView_Previews: PreviewProvider {
    static var previews: some View {
        PhysicalActivityViewTest()
            .environmentObject(TypeActivityViewModel())
    }
}



//ForEach(mealWithFood.foods) { food in
//    VStack(alignment: .leading) {
//        Text(food.nameFood)
//            .font(.system(size: 15))
//            .bold
//        HStack {
//            Text("Calories:\n\(String(format: "%0.f", food.caloriesByFood)) kcal")
//            Text("Protéines:\n\(String(format: "%0.f", food.proteins)) g")
//            Text("Glucides:\n\(String(format: "%0.f", food.carbs)) g")
//            Text("Graisses:\n\(String(format: "%0.f", food.fats)) g")
//        }
//        .multilineTextAlignment(.center)
//        .font(.subheadline)
//        .foregroundColor(.gray)
//    }
//}
