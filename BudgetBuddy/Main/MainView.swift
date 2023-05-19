//
//  MainView.swift
//  BudgetBuddy
//
//  Created by Yade KANBİR on 2.05.2023.
//

import SwiftUI

struct MainView: View {
    
    @State private var shouldPresentAddCardFrom = false
    
    @Environment (\.managedObjectContext) private var viewContext
    @FetchRequest (
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)], animation: .default)
    
    private var cards: FetchedResults<Card>
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !cards.isEmpty{
                    TabView{
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .padding(.bottom, 80)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 280)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                } else {
                    emptyPromptMessage
                }
                
                Spacer()
                    .fullScreenCover(isPresented: $shouldPresentAddCardFrom, onDismiss: nil) {
                        AddCardForm()
                    }
            }
            .navigationTitle("Credit Cards")
            .navigationBarItems(leading: HStack {
                addItemButton
                deleteAllButton
            }, trailing: addCardButton)
        }
    }
    
    private var emptyPromptMessage: some View {
        VStack{
            Text("You currently have no cards in the system.")
                .font(.system(size: 18, weight: .semibold))
                .padding(.vertical)
                .multilineTextAlignment(.center)
            Button {
                shouldPresentAddCardFrom.toggle()
            } label: {
                Text("+ Add Your First Card")
                    .foregroundColor(.white)
            }
            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
            .background(Color.blue)
            .cornerRadius(15)
        }
    }
    
    var deleteAllButton: some View {
        Button {
            cards.forEach { card in
                viewContext.delete(card)
            }
            do {
                try viewContext.save()
            } catch {
                
            }
        } label : {
            Text("Delete All")
        }
    }
    
    var addItemButton: some View {
        Button(action: {
            withAnimation {
                let viewContext = PersistenceController.shared.container.viewContext
                let card = Card(context: viewContext)
                card.timestamp = Date()
                
                do{
                    try viewContext.save()
                } catch {
                    
                }
            }
            
        }, label: {
            Text("Add Item")})
    }
    
    struct CreditCardView: View {
        
        let card: Card
        
        @State private var shouldShowActionSheet = false
        @State private var shouldShowEditForm = false
        @State var refreshId = UUID()
        
        private func handleDelete() {
            let viewContext = PersistenceController.shared.container.viewContext
            viewContext.delete(card)
            do {
                try viewContext.save()
            } catch {
                
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack{
                    Text(card.name ?? "")
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()
                    Button {
                        shouldShowActionSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .actionSheet(isPresented: $shouldShowActionSheet){
                        .init(title: Text(self.card.name ?? ""), message: Text("Options"),
                              buttons: [
                                .default(Text("Edit"), action: {
                                    shouldShowEditForm.toggle()
                                }),
                                .destructive(Text("Delete Card"), action: handleDelete),
                                        .cancel()
                              ])
                    }
                }

                HStack{
                    let imageName = card.type?.lowercased() ?? ""
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                        .clipped()
                    Spacer()
                    Text("Balance: $5,000")
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(card.number ?? "")
                HStack{
                    Text("Credit Limit: $\(card.limit)")
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Valid Thru")
                        Text("\(String(format: "%02d", card.expMonth + 1))/\(String(card.expYear % 2000))")
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(
                VStack {
                    if let colorData = card.color,
                       let uiColor = UIColor.color(data: colorData),
                       let actualColor = Color(uiColor) {
                        LinearGradient(colors:[
                            actualColor.opacity(0.6),
                            actualColor
                        ], startPoint: .center, endPoint: .bottom)
                    } else {
                        Color.cyan
                    }
                }
            )
            .cornerRadius(8)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)
            
            .fullScreenCover(isPresented: $shouldShowEditForm) {
                AddCardForm(card: self.card)
            }
        }
    }
    
    var addCardButton: some View {
        Button(action: {
            shouldPresentAddCardFrom.toggle()
        }, label: {
           Text("+ Card")
               .foregroundColor(.blue)
               .font(.system(size: 20, weight: .medium))
               .padding()
       })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, viewContext)
    }
}
