//
//  AllItemsCellView.swift
//  iOS15 Features
//
//  Created by Payton Sides on 6/9/21.
//

import SwiftUI

struct AllItemsCellView: View {
    
    //MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var persistenceController: PersistenceController
    
    @ObservedObject var item: Item
    @ObservedObject private var haptics = Haptics()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemList.timestamp, ascending: true)],
        animation: .default)
    private var lists: FetchedResults<ItemList>
    
    @Binding var editMode: EditMode
    
    var unpickedItems: [Item]
        
    @State private var name: String
    @State private var favoriteColor: Color = .pink.opacity(0.7)
    @State private var searchText = ""
    @State private var isEditingTitle = false
    @State private var nameIsFocused = false
    private let impactMed = UIImpactFeedbackGenerator(style: .rigid)
    
    init(item: Item, editMode: Binding<EditMode>, unpickedItems: [Item]) {
        self.item = item
        
        _name = State(wrappedValue: item.nameDisplay)
        self._editMode = editMode
        self.unpickedItems = unpickedItems
    }
    
    //MARK: - Body
    var body: some View {
        HStack {
            
            textFieldView
                .onTapGesture {
                    if nameIsFocused {
                        nameIsFocused = false
                    }
                }
            
            Spacer()
            Menu {
                ForEach(listsContaining(item), id: \.self) { list in
                    Text(list.trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .whitespaces))
                }
            } label: {
                HStack(spacing: 0) {
                    ForEach(listsContaining(item).prefix(3), id: \.self) { list in
                            
                            Text(list)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    if listsContaining(item).count > 3 {
                        Text("...")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            addItemButton
        }
    }
    
    //MARK: - Text Field View
    var textFieldView: some View {
        CustomTextField("", text: $name, isEditing: $nameIsFocused)
            .autocapitalization(.none)
            .returnKeyType(.done)
            .onReturn {
                if name == "" {
                    name = item.nameDisplay
                } else {
                    update(name)
                    nameIsFocused = false
                }
            }
            .frame(maxWidth: 150)
    }
    
    //MARK: - Add Item Button
    @ViewBuilder
    var addItemButton: some View {
        if editModeInactive {
            Menu {
                Text("Add to")
                
                if !item.isInUse {
                    Button {
                        withAnimation {
                            addToQuickList(item)
                            impactMed.impactOccurred()
                        }
                    } label: {
                        Text("Quick List")
                    }
                }
                
                ForEach(menuLists) { list in
                    Button {
                        withAnimation {
                            addTo(list)
                            impactMed.impactOccurred()
                        }
                    } label: {
                        Text(list.titleDisplay)
                    }
                }
                
                
            } label: {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
                    .foregroundColor(.mint)
            }
        }
    }
    
    //MARK: - Computed Properties
    var editModeInactive: Bool {
        switch editMode {
        case .active: return false
        case .inactive: return true
        case .transient: return true
        @unknown default:
            fatalError()
        }
    }
    
    var menuLists: [ItemList] {
        var menuLists: Array<ItemList> = []
        menuLists = Array(lists)

        listsContaining(item).forEach { listTitle in
            menuLists.removeAll(where: {$0.titleDisplay.contains(listTitle.trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .whitespaces))})
            print(menuLists.count)
        }
        
        return menuLists
    }
    
    //MARK: - Functions
    private func addToQuickList(_ item: Item) {
        withAnimation {
            
            item.isInUse = true
            item.order = Int16(unpickedItems.count + 1)
            item.lastModified = Date()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func update(_ name: String) {
        withAnimation {
    
            item.name = name
            item.lastModified = Date()
//            do {
                persistenceController.update(item)
//            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
        }
    }
    
    private func addTo(_ list: ItemList) {
        withAnimation {
            if persistenceController.fullVersionUnlocked {
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
    }
    
    func listsContaining(_ item: Item) -> [String] {
        var listsContainingItem: [String] = []
        if item.isInUse {
            listsContainingItem.append("Quick List")
        }
        lists.forEach { list in
            if list.listItems.filter({$0.nameDisplay == item.nameDisplay}).count != 0 {
                if listsContainingItem.isEmpty {
                    listsContainingItem.append(list.titleDisplay)
                } else {
                    listsContainingItem.append(", \(list.titleDisplay)")
                }
            }
        }
        
        if listsContainingItem.isEmpty {
            listsContainingItem.append("Last used \(item.modifiedDateOnly)")
        }
        
        return listsContainingItem
    }
}
