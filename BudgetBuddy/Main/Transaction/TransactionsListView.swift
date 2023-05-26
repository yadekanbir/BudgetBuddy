//
//  TransactionsListView.swift
//  BudgetBuddy
//
//  Created by Yade KANBİR on 26.05.2023.
//

import SwiftUI

struct TransactionsListView: View {
    
    @State private var shouldShowAddTransactionForm = false
    
    @Environment (\.managedObjectContext) private var viewContext
    @FetchRequest (
        sortDescriptors: [NSSortDescriptor(keyPath: \CardTransaction.timestamp, ascending: false)], animation: .default)
    
    private var transactions: FetchedResults<CardTransaction>
    
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
                AddTransactionForm()
            }
            
            ForEach (transactions) { transaction in
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
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        ScrollView{
            TransactionsListView()
        }
            .environment(\.managedObjectContext, context)
    }
}
