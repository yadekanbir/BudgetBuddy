//
//  MainView.swift
//  BudgetBuddy
//
//  Created by Yade KANBİR on 2.05.2023.
//

import SwiftUI

struct MainView: View {
    
    @State private var shouldPresentAddCardForm = false
    @State private var shouldShowAddTransactionForm = false
    
    @Environment (\.managedObjectContext) private var viewContext
    @FetchRequest (
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)], animation: .default)
    
    private var cards: FetchedResults<Card>
    
    @FetchRequest (
        sortDescriptors: [NSSortDescriptor(keyPath: \CardTransaction.timestamp, ascending: false)], animation: .default)
    
    private var transactions: FetchedResults<CardTransaction>
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !cards.isEmpty {
                    TabView{
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .padding(.bottom, 40)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 280)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    
                    Text("Get started by adding your first transaction")
                    
                    Button {
                        shouldShowAddTransactionForm.toggle()
                    } label: {
                        Text("+ Transaction")
                            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(CGFloat(5))
                    }
                    .fullScreenCover(isPresented: $shouldShowAddTransactionForm) {
                        AddTransactionForm()
                    }
                    
                    ForEach (transactions) { transaction in
                        VStack {
                            HStack {
                                VStack (alignment: .leading) {
                                    Text(transaction.name ?? "")
                                        .font(.headline)
                                    
                                    if let date = transaction.timestamp {
                                        Text(dateFormatter.string(from: date))
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Button {
                                        
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 24))
                                    }
                                    .padding(CGFloat(5))
                                    
                                    Text(String(format: "$%.2f", transaction.amount ))
                                }
                            }
                            
                            if let photoData = transaction.photoData,
                               let uiImage = UIImage(data: photoData){
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                            .foregroundColor(Color(.label))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(5)
                            .shadow(radius: 5)
                            .padding()
                    }
                     
                } else {
                    emptyPromptMessage
                }
                
                Spacer()
                    .fullScreenCover(isPresented: $shouldPresentAddCardForm, onDismiss: nil) {
                        AddCardForm()
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
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
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
