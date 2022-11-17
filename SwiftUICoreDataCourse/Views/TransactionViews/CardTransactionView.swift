//
//  CardTransactionView.swift
//  SwiftUICoreDataCourse
//
//  Created by CMDB-127710 on 17.11.2022.
//

import SwiftUI

struct CardTransactionView: View {

    @State var shouldPresentActionSheet = false
    var transaction: CardTransaction

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.name ?? "")
                        .font(.headline)
                    if let date = transaction.timestamp {
                        Text(dateFormatter.string(from: date))
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    ellipsisButton
                        .padding(EdgeInsets(top: 6, leading: 8,
                                            bottom: 4, trailing: 0))
                    Text(String(format: "$%.2f", transaction.amount))
                }
            }
            if let imageData = transaction.photoData,
                let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding()
        .foregroundColor(Color(.label))
    }

    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    private var ellipsisButton: some View {
        Button {
            shouldPresentActionSheet.toggle()
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 24))
        }
        .actionSheet(isPresented: $shouldPresentActionSheet) {
            .init(title: Text(transaction.name ?? ""),
                  message: Text("Edit transaction"), buttons: [
                    .destructive(Text("Delete"), action: handleDelete),
                    .cancel()
                  ])
        }
    }

    private func handleDelete() {
        withAnimation {
            let context = PersistenceController.shared.container.viewContext
            context.delete(transaction)
            do {
                try context.save()
            } catch {
                debugPrint("Failed to delete transaction")
            }
        }
    }
}
