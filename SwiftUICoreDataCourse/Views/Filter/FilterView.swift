import SwiftUI

struct FilterView: View {

    @Environment(\.presentationMode) var presentationMode

    @State var selectedCategories: Set<TransactionCategory>

    var didSaveFilters: (Set<TransactionCategory>) -> ()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories: FetchedResults<TransactionCategory>

    var body: some View {
        NavigationView {
            Form {
                ForEach(categories) { category in
                    Button {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            if let colorData = category.color, let
                                uiColor = UIColor.color(data: colorData) {
                                let color = Color(uiColor: uiColor)
                                Spacer()
                                    .frame(width: 30, height: 10)
                                    .background(color)
                            }
                            Text(category.name ?? "")
                                .foregroundColor(Color(.label))
                            Spacer()
                            if selectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                } 
            }
            .navigationTitle("Select filters")
            .navigationBarItems(trailing: saveButton)
        }
    }

    private var saveButton: some View {
        Button {
            didSaveFilters(selectedCategories)
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Save")
        }
    }
}
