//
//  TransactionsListView.swift
//  BudgetBuddy
//
//  Created by Yade KANBİR on 26.05.2023.
//

import SwiftUI

struct TransactionsListView: View {
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        
        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)], predicate: .init(format: "card == %@", self.card))
    }
    
    @State private var shouldShowAddTransactionForm = false
    
    @Environment (\.managedObjectContext) private var viewContext
    
    var fetchRequest: FetchRequest<CardTransaction>
    
    var body: some View {
        VStack {
            Text("Add your new transaction")
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
                AddTransactionForm(card: self.card)
            }
            
            ForEach (fetchRequest.wrappedValue) { transaction in
                CardTransactionView(transaction: transaction)
            }
        }
    }
}

public struct CardTransactionView: View {
    
    let transaction: CardTransaction
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    @State var shouldPresentActionSheet = false
    
    private func handleDelete() {
        withAnimation {
            do {
            let viewContext = PersistenceController.shared.container.viewContext
            viewContext.delete(transaction)
            try viewContext.save()
            } catch {
                print("error")
            }
        }
    }
    
    public var body: some View {
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
                        shouldPresentActionSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24))
                    }
                    .padding(CGFloat(5))
                    .actionSheet(isPresented: $shouldPresentActionSheet) {
                        .init(title: Text(transaction.name ?? ""), message: nil,
                              buttons: [.destructive(Text("Delete Card"), action: handleDelete),
                                        .cancel()
                                        ])
                    }
                    
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
}

struct TransactionsListView_Previews: PreviewProvider {
    
    static let firstCard: Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request = Card.fetchRequest()
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        return try? context.fetch(request).first
    }()
    
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        ScrollView{
            if let card = firstCard {
                TransactionsListView(card: card)
            }
        }
            .environment(\.managedObjectContext, context)
    }
}
