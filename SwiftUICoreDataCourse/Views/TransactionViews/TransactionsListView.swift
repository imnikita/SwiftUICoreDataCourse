import SwiftUI

struct TransactionsListView: View {

    let card: Card

    init(card: Card) {
        self.card = card

        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [
            .init(key: "timestamp", ascending: false)
        ], predicate: .init(format: "card == %@", self.card))
    }

    @Environment(\.managedObjectContext) private var viewContext

    @State private var shouldShowTransactionForm = false

    var fetchRequest: FetchRequest<CardTransaction>

    var body: some View {
        VStack {
            Text("Get started by adding your first transaction")
            addTransactionButton
            ForEach(fetchRequest.wrappedValue) { transaction in
                CardTransactionView(transaction: transaction)
            }
        }
    }

    private var addTransactionButton: some View {
        Button {
            shouldShowTransactionForm.toggle()
        } label: {
            Text("+ Transaction")
                .padding(EdgeInsets(top: 10, leading: 14,
                                    bottom: 10, trailing: 14))
                .background(Color(.label))
                .foregroundColor(Color(.systemBackground))
                .font(.headline)
                .cornerRadius(5)
        }
        .fullScreenCover(isPresented: $shouldShowTransactionForm) {
            AddTransactionView(card: card)
        }
    }
}

/// The commented part below is needed for convenient switching between previews
struct TransactionView_Previews: PreviewProvider {

    static let firstCard: Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request = Card.fetchRequest()
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        return try? context.fetch(request).first
    }()

    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
//        MainView()
        ScrollView {
            if let card = firstCard {
                TransactionsListView(card: card)
            }
        }
            .environment(\.managedObjectContext, viewContext)
    }
}
