//
//  AddTransactionView.swift
//  SwiftUICoreDataCourse
//
//  Created by CMDB-127710 on 17.11.2022.
//

import SwiftUI

struct AddTransactionView: View {

    let card: Card

    @Environment(\.presentationMode) var presentationMode
    @State private var shouldPresentPhotoPicker = false
    @State private var name = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var photoData: Data?

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Information")) {
                    TextField("Name", text: $name)
                    TextField("Amount", text: $amount)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    manyToManyLink
                }

                Section(header: Text("PHOTO/RECEIPT")) {
                    Button {
                        shouldPresentPhotoPicker.toggle()
                    } label: {
                        Text("Select photo")
                    }
                    .fullScreenCover(isPresented: $shouldPresentPhotoPicker) {
                        PhotoPickerView(photoData: $photoData)
                    }
                    if let imageData = photoData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
            .navigationTitle(Text("Add transaction"))
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }

    private var manyToManyLink: some View {
        NavigationLink {
            Text("New category")
                .navigationTitle("Title")
        } label: {
            Text("many to many")
        }
    }

    private var cancelButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Cancel")
        }
    }

    private var saveButton: some View {
        Button {
            let context = PersistenceController.shared.container.viewContext
            let transaction = CardTransaction(context: context)
            transaction.name = name
            transaction.amount = Float(amount) ?? 0.0
            transaction.timestamp = date
            transaction.photoData = photoData
            transaction.card = card
            do {
                try context.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                debugPrint("Transaction saving error: \(error.localizedDescription)")
            }

        } label: {
            Text("Save")
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {

    static let firstCard: Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request = Card.fetchRequest()
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        return try? context.fetch(request).first
    }()

    static var previews: some View {
        if let card = firstCard {
            AddTransactionView(card: card)
        }
    }
}
