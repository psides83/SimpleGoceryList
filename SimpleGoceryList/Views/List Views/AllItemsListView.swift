//
//  AllItemsListView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/11/21.
//

import SwiftUI

struct AllItemsListView: View {
    
    //MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var persistenceController: PersistenceController
    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @FetchRequest(
        entity: ItemList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemList.timestamp, ascending: true)],
        animation: .default)
    private var lists: FetchedResults<ItemList>
    
    @State private var nameText = ""
    @State private var searchText = ""
    @State private var editMode = EditMode.inactive
    @State private var showingDeletePickedItemsConfirmation = false
    @State private var selection = Set<Item>()
    
    var body: some View {
        allItemsList
    }
    
    //MARK: - All List
    var allItemsList: some View {
        NavigationView {
            List(selection: $selection) {
                Section(header: headerView) {
                    ForEach(allItems, id: \.self) { item in
                        AllItemsCellView(item: item, editMode: $editMode, unpickedItems: unpickedItems)
                    }
                    .onDelete { offsets in
                        let allItems = allItems
                        
                        for offset in offsets {
                            let item = allItems[offset]
                            delete(item)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .add(SearchBar(text: $searchText), searchBarCoordinator: SearchBar.Coordinator(text: $searchText))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("History")
            .navigationBarItems(leading: backButton, trailing: EditButton())
            .environment(\.editMode, self.$editMode)
            .onChange(of: editMode, perform: { value in
                unselectAll()
            })
        }
        .accentColor(.orangeLight)
    }
    
    //MARK: - Header View
    var headerView: some View {
        HStack(alignment: .bottom) {
            
            if editMode == .active {
                
                removeButton
                
                Spacer()
                
                addButton
            } else {
                headerLabel
            }
        }
    }
    
    //MARK: - Header Label
    @ViewBuilder
    var headerLabel: some View {
        Image(systemName: "clock")
            .font(.title2.weight(.bold))
            .foregroundColor(.orangeLight)
            .padding(.leading, 6)
        
        Text("Search, edit, or add items to the current list")
            .font(.subheadline)
            .textCase(.none)
            .transition(.opacity)
    }
    
    //MARK: - Back Button
    var backButton: some View {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack(spacing: 0) {
                    Image(systemName: "chevron.left")
                    
                    Text("Picked")
                }
            }
            .accentColor(.mint)
    }
    
    //MARK: - Remove Button
    var removeButton: some View {
        Button {
            showingDeletePickedItemsConfirmation = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .buttonStyle(SelecttionActionButton(color: .red.opacity(0.8)))
        .animation(.easeInOut, value: showingDeletePickedItemsConfirmation)
        .alert(isPresented: $showingDeletePickedItemsConfirmation, content: {
            Alert(title: Text("Delete selected items?"), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Ok"), action: deleteSelected))
        })
    }
    
    //MARK: - Add Button
    var addButton: some View {
        Menu {
            Text("Add to")
            Button {
                addSelected()
            } label: {
                Text("Quick List")
            }
            
            ForEach(lists) { list in
                Button {
                    addSelectedTo(list)
                } label: {
                    Text(list.titleDisplay)
                }
            }
        } label: {
            Label("Add", systemImage: "plus")
        }
        .font(.subheadline.weight(.semibold))
        .textCase(.none)
        .foregroundColor(.white)
        .padding(5)
        .background(Color.mint.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
        .padding(.trailing)
    }
    
    //MARK: - Fetch Results
    var allItems: [Item] {
        withAnimation {
            items.filter({searchText.isEmpty ? true : $0.nameDisplay.localizedCaseInsensitiveContains(searchText)}).sorted(by: {$0.nameDisplay.lowercased() < $1.nameDisplay.lowercased()})
        }
    }
    
    var unpickedItems: [Item] {
        withAnimation {
            items.filter({!$0.isPicked && $0.isInUse}).sorted(by: {$0.order < $1.order})
        }
    }
    
    //MARK: - Functions
    private func delete(_ item: Item) {
        withAnimation {
            viewContext.perform {
                persistenceController.delete(item)
                
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
    
    private func deleteSelected() {
        for item in selection {
            withAnimation {
                persistenceController.delete(item)
            }
            selection = Set<Item>()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func unselectAll() {
        if editMode == .inactive {
            selection.removeAll()
        }
    }
    
    private func addSelected() {
        for item in selection {
            withAnimation {
                item.isPicked = false
                item.isInUse = true
                item.lastModified = Date()
            }
        }
        selection = Set<Item>()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func addSelectedTo(_ list: ItemList) {
        withAnimation {
            if persistenceController.fullVersionUnlocked {
                for item in selection {
                    if list.listItems
                        .filter({ $0.nameDisplay
                                    .localizedCaseInsensitiveContains(item.nameDisplay.lowercased())})
                        .count == 0 {
                        
                        let newItem = ListItem(context: viewContext)
                        newItem.id = UUID()
                        newItem.name = item.name
                        newItem.image = item.image
                        newItem.quantity = 1
                        newItem.order = Int16(list.unpickedItems.count + 1)
                        newItem.isPicked = false
                        newItem.lastModified = Date()
                        newItem.timestamp = Date()
                        newItem.list = list
                        
                        item.lastModified = Date()
//                persistenceController.update(newItem)
//                sharedItemRepo.addItem(name: nameText, timestamp: Date(), isInUse: true, isPicked: false, isUrgent: false, lastModified: Date(), order: Int64(unpickedItems.count + 1), quantity: 1){ _ in
//                        isAddingList = true
//                }
                        
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
                selection = Set<Item>()
                
            }
        }
    }
}

//MARK: - Preview
struct AllItemsListView_Previews: PreviewProvider {
    static var previews: some View {
        AllItemsListView()
    }
}
