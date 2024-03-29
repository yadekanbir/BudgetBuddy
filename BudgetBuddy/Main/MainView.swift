//
//  MainView.swift
//  BudgetBuddy
//
//  Created by Yade KANBİR on 2.05.2023.
//

import SwiftUI

struct MainView: View {
    
    @State private var shouldPresentAddCardForm = false
    
    @Environment (\.managedObjectContext) private var viewContext
    
    @FetchRequest (
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)], animation: .default)
    private var cards: FetchedResults<Card>
    
    @State private var cardSelectionIndex = 0
    @State private var selectedCardHash = -1
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !cards.isEmpty {
                    TabView(selection: $selectedCardHash) {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .padding(.bottom, 50)
                                .tag(card.hash)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(height: 280)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .onAppear {
                            self.selectedCardHash = cards.first?.hash ?? -1
                        }
                    
                    if let firstIndex = cards.firstIndex(where: {
                        $0.hash == selectedCardHash }) {
                        let card = self.cards[firstIndex]
                        TransactionsListView(card: card)
                    }
                    
                } else {
                    emptyPromptMessage
                }
                
                Spacer()
                    .fullScreenCover(isPresented: $shouldPresentAddCardForm, onDismiss: nil) {
                        AddCardForm(card: nil) { card in
                            self.selectedCardHash = card.hash
                        }
                    }
            }
            .navigationTitle("Credit Cards")
            .navigationBarItems(trailing: addCardButton)
        }
    }
    
    private var emptyPromptMessage: some View {
        VStack{
            Text("You currently have no cards in the system.")
                .font(.system(size: 18, weight: .semibold))
                .padding(.vertical)
                .multilineTextAlignment(.center)
            Button {
                shouldPresentAddCardForm.toggle()
            } label: {
                Text("+ Add Your First Card")
                    .foregroundColor(.white)
            }
            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
            .background(Color.blue)
            .cornerRadius(15)
        }
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
                        .frame(height: 48)
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
            shouldPresentAddCardForm.toggle()
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
        let viewContext = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, viewContext)
    }
}
