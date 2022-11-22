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
    @State private var shouldShowFilterSheet = false
    @State private var selectedCategories = Set<TransactionCategory>()

    var fetchRequest: FetchRequest<CardTransaction>

    var body: some View {
        VStack {
            if fetchRequest.wrappedValue.isEmpty {
                Text("Get started by adding your first transaction")
                addTransactionButton
            } else {
                HStack( spacing: 12) {
                    Spacer()
                    addTransactionButton
                    filterButton
                }
                .padding(.horizontal)
                ForEach(filterTransactions(selectedCategories: selectedCategories)) { transaction in
                    CardTransactionView(transaction: transaction)
                }
            }
        }
        .fullScreenCover(isPresented: $shouldShowTransactionForm) {
            AddTransactionView(card: card)
        }
    }

    private func filterTransactions(selectedCategories: Set<TransactionCategory>) -> [CardTransaction] {
        if selectedCategories.isEmpty {
            return Array(fetchRequest.wrappedValue)
        }

        return fetchRequest.wrappedValue.filter { transaction in
            var shouldKeep = false

            if let categories = transaction.categories as? Set<TransactionCategory> {
                categories.forEach { category in
                    if selectedCategories.contains(category) {
                        shouldKeep = true
                    }
                }
            }
            return shouldKeep
        }
    }

    private var filterButton: some View {
        Button {
            shouldShowFilterSheet.toggle()
        } label: {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text("Filter")
            }
            .padding(EdgeInsets(top: 10, leading: 14,
                                bottom: 10, trailing: 14))
            .background(Color(.label))
            .foregroundColor(Color(.systemBackground))
            .font(.headline)
            .cornerRadius(5)
        }
        .sheet(isPresented: $shouldShowFilterSheet) {
            FilterView(selectedCategories: selectedCategories) { categories in
                selectedCategories = categories
            }
        }
    }

    private var addTransactionButton: some View {
        return Button {
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
