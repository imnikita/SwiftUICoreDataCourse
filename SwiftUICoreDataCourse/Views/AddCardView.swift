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
            .navigationTitle(Text("Add Credit Card"))
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Cancel")
            }))
        }
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView()
    }
}
