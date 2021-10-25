//
//  AddListView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 7/15/21.
//

import SwiftUI

struct AddListView: View {
    
    //MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var persistenceController: PersistenceController
    @EnvironmentObject private var sharedItemRepo: SharedItemRepo
    
    @State private var titleText = ""
    @State private var titleIsFocused = false
    @State private var isAddingList = false
    
    var body: some View {
        NavigationView {
            Form {
                CustomTextField("new list", text: $titleText, isEditing: $titleIsFocused)
                    .autocapitalization(.words)
                    .returnKeyType(.done)
                    .showsClearButton(titleIsFocused)
                    .onClear {
                        
                        titleIsFocused = false
                        titleText = ""
                        hideKeyboard()
                    }
            }
        }
    }
    
    //MARK: - Functions
    private func addList() {
        
//        let canCreate = persistenceController.fullVersionUnlocked || persistenceController.count(for: ItemList.fetchRequest()) < 10
//        if canCreate {
            withAnimation {
                let newList = ItemList(context: viewContext)
                newList.id = UUID()
                newList.title = titleText
                newList.timestamp = Date()
                
                persistenceController.update(newList)
//                sharedItemRepo.addList() { _ in
//                        isAddingList = true
//                }
                titleText = ""
            }
//        } else {
//            titleIsFocused = false
//            hideKeyboard()
//            titleText = ""
//        }
    }
}

struct AddListView_Previews: PreviewProvider {
    static var previews: some View {
        AddListView()
    }
}
