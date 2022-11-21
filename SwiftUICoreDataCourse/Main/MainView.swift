import SwiftUI

struct MainView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var shouldPresentAddCardForm = false
    @State private var cardSelectionIndex = 0
    @State private var selectedCardHash = -1

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>

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

                    if let cardIndex = cards.firstIndex(where: { $0.hash == selectedCardHash}) {
                        TransactionsListView(card: cards[cardIndex])
                    }
                } else {
                    VStack {  
                        Group {
                            Text("You are currently have no cards in the system")
                                .padding(.horizontal, 48)
                                .padding(.vertical)
                                .multilineTextAlignment(.center)
                            addFirstCardButton
                        }
                        .font(.system(size: 24, weight: .semibold))
                    }
                }
                Spacer()
                    .fullScreenCover(isPresented: $shouldPresentAddCardForm) {
                        AddCardView(card: nil) { card in
                            self.selectedCardHash = card.hash
                        }
                    }
            }
            .navigationTitle("Credit card")
            .navigationBarItems(leading: leadingNavBarButtons,
                                trailing: addCardButton)
        }
    }

    // MARK: - CreditCardView
    struct CreditCardView: View {

        @State private var shouldShowActionSheet = false
        @State private var shouldShowEditForm = false
        let card: Card

        private func handleDelete() {
            let viewContext = PersistenceController.shared.container.viewContext
            viewContext.delete(card)
            do {
                try viewContext.save()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(card.name ?? "")
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()
                    ellipsisButton
                }
                HStack {
                    let imageName = card.type?.lowercased() ?? "Visa"
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                        .clipped()

                    Spacer()
                    Text("Balance: \(card.limit)$")
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(card.number ?? "")
                HStack {
                    Text("Credit Limit: $\(card.limit)")
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Valid to:")
                        Text("\(String(format: "%02d", card.expMonth))/\(String(card.expYear % 2000))")
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(
                VStack {
                    if let colorData = card.color,
                        let uiColor = UIColor.color(data: colorData),
                    let color = Color(uiColor) {
                        LinearGradient(colors: [
                            color.opacity(0.6),
                            color
                        ], startPoint: .top, endPoint: .bottom)
                    } else {
                        Color.cyan
                    }
                }
            )
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(8)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)
            .fullScreenCover(isPresented: $shouldShowEditForm) {
                AddCardView(card: card)
            }
        }

        private var ellipsisButton: some View {
            Button {
                shouldShowActionSheet.toggle()
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 28, weight: .bold))
            }
            .actionSheet(isPresented: $shouldShowActionSheet) {
                .init(title: Text(card.name ?? ""), message: Text("Options"), buttons: [
                    .default(Text("Edit"), action: {
                        shouldShowEditForm.toggle()
                    }),
                    .destructive(Text("DELETE"), action: handleDelete),
                    .cancel()
                ])
            }
        }
    }

    // MARK: - Views
    private var leadingNavBarButtons: some View {
        HStack {
            addItemButton
            deleteAllButton
        }
    }

    private var addCardButton: some View {
        Button(action: {
            shouldPresentAddCardForm.toggle()
        }, label: {
            Text("+ Card")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(Color.black)
                .cornerRadius(5)
        })
    }

    private var deleteAllButton: some View {
        Button {
            cards.forEach { card in
                viewContext.delete(card)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        } label: {
            Text("Delete All")
        }

    }

    private var addItemButton: some View {
        Button(action: {
            withAnimation {
                let viewContext = PersistenceController.shared.container.viewContext
                let card = Card(context: viewContext)
                card.timestamp = Date()
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }, label: {
            Text("Add Item")
        })
    }

    private var addFirstCardButton: some View {
        Button {
            shouldPresentAddCardForm.toggle()
        } label: {
            Text("+ Add your first card")
                .foregroundColor(Color(.systemBackground))
        }
        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
        .background(Color(.label))
        .cornerRadius(5)
    }
}

/// The commented part below is needed for convenient switching between previews
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, viewContext)
//        AddCardView()
    }
}
