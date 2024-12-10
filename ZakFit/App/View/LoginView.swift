//
//  LoginView.swift
//  ZakFit
//
//  Created by Klesya on 10/12/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var emailInput: String = "Salut"
    var body: some View {
        VStack {
            Image("zakfit_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 348.0, height: 167.0)
            
            TextField("Email", text: $emailInput)
                .frame(width: 187, height: 49)
                .background(.grey)
                .cornerRadius(24)
            
            Text(emailInput)
                .bold()
                .font(.system(size: 13))
            
            Rectangle()
                .foregroundStyle(.grey)
                .cornerRadius(24)
                .frame(width: 187, height: 49)
            
            Rectangle()
                .foregroundStyle(.grey)
                .cornerRadius(24)
                .frame(width: 187, height: 49)
        }
    }
}

#Preview {
    LoginView()
}
