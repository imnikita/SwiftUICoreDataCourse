import SwiftUI

struct AddCardView: View {

    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var cardNumber  = ""
    @State private var creditLimit = ""
    @State private var cardType = "Visa"
    @State private var month = 1
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var color = Color.blue
    private var currentYear = Calendar.current.component(.year, from: Date())

    let card: Card?
    var didAddCard: ((Card) -> ())? = nil

    init(card: Card? = nil, didAddCard: ((Card) -> ())? = nil) {
        self.card = card
        self.didAddCard = didAddCard
        _name = State(initialValue: self.card?.name ?? "")
        _cardNumber = State(initialValue: self.card?.number ?? "")
        if let limit = self.card?.limit {
            _creditLimit = State(initialValue: String(limit))
        }
        if let colorData = self.card?.color,
            let uiColor = UIColor.color(data: colorData) {
            let color = Color(uiColor)
            _color = State(initialValue: color)
        }
        _cardType = State(initialValue: card?.type ?? "")
        _month = State(initialValue: Int(self.card?.expMonth ?? 1))
        _month = State(initialValue: Int(self.card?.expYear ?? Int16(currentYear)))
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Credit card number", text: $cardNumber)
                        .keyboardType(.numberPad)
                    TextField("Credit limit", text: $creditLimit)
                        .keyboardType(.numberPad)
                    Picker("Type", selection: $cardType) {
                        ForEach(["Visa", "Master Card", "Discover"], id: \.self) { cardType in
                            Text(String(cardType)).tag(String(cardType))
                        }
                    }
                } header: {
                    Text("Card information")
                }

                Section {
                    Picker("Month", selection: $month) {
                        ForEach(1..<13, id: \.self) { num in
                            Text(String(num)).tag(String(num))
                        }
                    }
                    Picker("Year", selection: $year) {
                        ForEach(currentYear..<currentYear + 20, id: \.self) { num in
                            Text(String(num)).tag(String(num))
                        }
                    }
                } header: {
                    Text("Expiration")
                }

                Section {
                    ColorPicker("Color", selection: $color)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle(Text( self.card != nil ? self.card?.name ?? "" : "Add Credit Card"))
            .navigationBarItems(leading: cancelButton,
                                trailing: saveButton)
        }
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }

    private var saveButton: some View {
        Button(action: {
            let viewContext = PersistenceController.shared.container.viewContext
            let card = self.card != nil ? self.card! : Card(context: viewContext)
            card.name = self.name
            card.number = self.cardNumber
            card.limit = Int32(self.creditLimit) ?? 0
            card.expMonth = Int16(self.month)
            card.expYear = Int16(self.year)
            card.timestamp = Date()
            card.color = UIColor(color).encode()
            card.type = cardType.replacingOccurrences(of: " ", with: "")
            do {
                try viewContext.save()
                didAddCard?(card)
                presentationMode.wrappedValue.dismiss()
            } catch {
                debugPrint("Persistent error: \(error.localizedDescription)")
            }
        }, label: {
            Text("Save")
        })
    }
}

/// The commented part below is needed for convenient switching between previews
struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
//        AddCardView()
        MainView()
            .environment(\.managedObjectContext, viewContext)
    }
}
