//
//  MainView.swift
//  BudgetBuddy
//
//  Created by Yade KANBİR on 2.05.2023.
//

import SwiftUI

struct MainView: View {
    
    @State private var shouldPresentAddCardFrom = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                TabView{
                    ForEach(0..<5) { num in
                        CreditCardView()
                            .padding(.bottom, 40)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 280)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
             
                Spacer()
                    .fullScreenCover(isPresented: $shouldPresentAddCardFrom, onDismiss: nil) {
                        AddCardForm()
                    }
            }
            .navigationTitle("Credit Cards")
            .navigationBarItems(trailing: addCardButton)
        }
    }
    
    struct CreditCardView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Apple Blue Visa Card")
                    .font(.system(size: 24, weight: .semibold))
                HStack{
                    Image("visa")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                    
                    Spacer()
                    Text("Balance: $5,000")
                        .font(.system(size: 18, weight: .semibold))
                }
                Text("1234 1234 1234 1234")
                Text("Credit Limit: $50,000")
                HStack{Spacer()}
            }
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient(colors:[
                Color.blue.opacity(0.5),
                Color.blue
            ], startPoint: .center, endPoint: .bottom)
            )
            .cornerRadius(8)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
    
    var addCardButton: some View {
        Button(action: {
            shouldPresentAddCardFrom.toggle()
        }, label: {
           Text("+ Card")
               .foregroundColor(.black)
               .font(.system(size: 20, weight: .medium))
               .padding()
       })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
