import SwiftUI

struct CategoriesListView: View {

    @Binding var selectedCategories: Set<TransactionCategory>
    
    @State private var name = ""
    @State private var color = Color.red

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories: FetchedResults<TransactionCategory>

    var body: some View {
        Form {
            Section(header: Text("Select a category")) {
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
                .onDelete { indexSet in
                    handleDelete(from: indexSet) 
                }
            }

            Section(header: Text("Create a category")) {
                TextField("Name", text: $name)
                ColorPicker("Color", selection: $color)
                createButton
            }
        }
    }

    var createButton: some View {
        Button {
            handleCreate()
        } label: {
            HStack {
                Spacer()
                Text("Create")
                    .foregroundColor(Color.white)
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(5)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func handleDelete(from indexSet: IndexSet) {
        indexSet.forEach { index in
            let category = categories[index]
            selectedCategories.remove(category)
            viewContext.delete(category)
        }
        try? viewContext.save()
    }

    private func handleCreate() {
        let context = PersistenceController.shared.container.viewContext
        let category = TransactionCategory(context: context)
        category.name = self.name
        category.color = UIColor(color).encode()
        category.timestamp = Date()
        try? context.save()
        self.name = ""
    }
}

struct CategoriesListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesListView(selectedCategories: .constant(Set<TransactionCategory>()))
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
