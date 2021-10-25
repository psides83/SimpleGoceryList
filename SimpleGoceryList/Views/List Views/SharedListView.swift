//
//  SharedListView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 7/16/21.
//

import SwiftUI
import CloudKit
import CoreData
import Foundation
import AVFoundation
import CoreSpotlight

struct SharedListView: View {
    //MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    @EnvironmentObject var persistenceController: PersistenceController
    @EnvironmentObject private var sharedItemRepo: SharedItemRepo
    
    private let newItemActivity = "PaytonSides.SimpleGoceryList.newItem"
    
//    @ObservedObject var audioRecorder: AudioRecorder
    
    let ckList: CKList
    
    @FetchRequest(
        entity: ListItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ListItem.timestamp, ascending: true)],
        animation: .default)
    private var listItems: FetchedResults<ListItem>
    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
//    @AppStorage("v2point3") var v2point3: Bool = true
    
    @State private var ckItems = [CKItem]()
    @State private var itemsLoadState = LoadState.inactive
    
    @State private var nameText = ""
    @State private var unpickedIcon = "circle"
    @State private var pickedIcon = "checkmark.circle.fill"
    @State private var editMode: EditMode = .inactive
    @State private var showingClearAllConfirmation = false
    @State private var showingClearPickedConfirmation = false
    @State private var isShowingAllItemsView = false
    @State private var showingDuplicateToast = false
    @State private var selection = Set<ListItem>()
    @State private var nameIsFocused = false
    @State private var isShowingIntroPage = true
    @State private var isShowingUnlockView = false
    @State private var isAddingList = false
    @State private var dataState: DataState = .loaded
    
    //MARK: - Body
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 0) {
                    List(selection: $selection) {
                        
                        /// Section of unpicked itens
                        unpickedSection
                        
                        /// If user is inputting text and premium version of app is unlocked
                        if !nameIsFocused && pickedItems.count != 0 {
                            
                            /// Thr section of picked items only shows if the array has at least one item
                            
                            /// Section of picked itens
                            pickedSection
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationBarTitle(ckList.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading: backButton, trailing: EditButton())
                    .environment(\.editMode, $editMode)
                    
                    if nameIsFocused {
                        searchList
                            .background(Color.systemGroupedBackground)
                    }
                    
//                    HStack {
//                        Button(action: {
//                            sharedItemRepo.addList(title: ckList.title, timestamp: list.timestamp, list: list) { _ in
//                                isAddingList = false
//                            }
//
//                        }, label: {
//                            Text("Merge CloudKit")
//                        })
////
//////                        Button(action: {shareContact(item)}, label: {
//////                            /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
//////                        })
//                    }
                }
                .onChange(of: editMode, perform: { value in
                    unselectAll()
                })
            }
            .onAppear {
                fetchSharedItems(list: ckList)
            }
//            .sheet(isPresented: $isShowingUnlockView, content: {
//                UnlockView()
//            })
            
//            if showingDuplicateToast && !v2point3 {
//                DuplicateToastView()
//                    .scaleEffect()
//                    .animation(.easeInOut(duration: 1), value: showingDuplicateToast)
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            withAnimation {
//
//                                showingDuplicateToast = false
//                            }
//                        }
//                    }
//            }
            
            
//            if isShowingIntroPage {
//
//                IntroView(isShowingIntroPage: $isShowingIntroPage)
//                    .edgesIgnoringSafeArea(.all)
//                    .opacity(isShowingIntroPage ? 1 : 0)
//                    .animation(.easeIn(duration: 0.5), value: isShowingIntroPage)
//            }
            
        }
        .accentColor(.mint)
    }
    
    //MARK: - Add Item TextField
    var inputTextField: some View {
        VStack {
            
            CustomTextField("add item", text: $nameText, isEditing: $nameIsFocused)
                .autocapitalization(.none)
                .returnKeyType(.done)
                .onReturn {
                    if nameText.isEmpty {
                        
                        hideKeyboard()
                    } else {
                        if duplicateInUse.count != 0 {
                            
                            showingDuplicateToast = true
                            nameText = ""
                            nameIsFocused = true
                        } else if duplicateNotInUse.count != 0 {
                            duplicateNotInUse.forEach { item in
                                
                                addToList(item)
                                nameText = ""
                                nameIsFocused = true
                            }
                        } else {
                            
                            addItem()
                            nameIsFocused = true
                        }
                    }
                }
                .showsClearButton(nameIsFocused)
                .onClear {
                    
                    nameIsFocused = false
                    nameText = ""
                    hideKeyboard()
                }
                .textCase(.lowercase)
        }
    }
    
    //MARK: - Unpicked Section
    var unpickedSection: some View {
        Section(header:
                    HStack {
                        
                        ListIconView(backgroundColor: .mint, circleColor: .white, lineColor: .picked, topCircleIcon: unpickedIcon, bottomCircleIcon: unpickedIcon, scale: 0.95)
                            .padding(.leading)
                            .padding(.top, 8)
                        
                        Spacer()
                        
                        removeUnpickedButton
                    }
        ) {
            ForEach(unpickedItems) { item in
                ZStack {
                    
                    CKItemCellView(item: item, list: ckList, editMode: $editMode)
                }
            }
//            .onMove(perform: { indices, newOffset in
//
//                move(from: indices, to: newOffset)
//            })
//            .onDelete { offsets in
//
//                let allItems = unpickedItems
//
//                for offset in offsets {
//                    let item = allItems[offset]
//                    removeFromList(item)
//                }
//            }
            
            inputTextField
                .onTapGesture {
                    if nameIsFocused {
                        nameIsFocused = false
                    }
                }
        }
    }
    
    //MARK: - Picked Section
    var pickedSection: some View {
        Section(header:
                    HStack {
                        
                        ListIconView(backgroundColor: .picked, circleColor: .mint, lineColor: .white, topCircleIcon: pickedIcon, bottomCircleIcon: pickedIcon, scale: 0.95)
                            .padding(.leading)
                            .padding(.top, 8)
                        
                        Spacer()
                        
                        if editMode == .active && selection.filter({$0.isPicked == true}).count != 0 {
                            Button {
                                withAnimation {
                                    showingClearPickedConfirmation.toggle()
                                }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                            .buttonStyle(SelecttionActionButton(color: .red.opacity(0.8)))
                            .animation(.easeInOut, value: showingClearAllConfirmation)
                            .alert(isPresented: $showingClearPickedConfirmation, content: {
                                Alert(title: Text("Remove selected?"), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Ok"), action: deleteSelected))
                            })
                        }
                    }
        ) {
            ForEach(pickedItems) { item in
                
                CKItemCellView(item: item, list: ckList, editMode: $editMode)
            }
//            .onDelete { offsets in
//                let allItems = pickedItems
//                
//                for offset in offsets {
//                    let item = allItems[offset]
//                    removeFromList(item)
//                }
//            }
        }
    }
    
    //MARK: - Search List
    var searchList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center) {
                ForEach(textFieldResults) { item in
                    Button {
                        withAnimation {
                            
                            addToList(item)
                            nameText = ""
                        }
                    } label: {
                        
                        SearchCellView(item: item)
                    }
                }
            }
        }
    }
    
    //MARK: - Remove Button
    
    @ViewBuilder
    var removeUnpickedButton: some View {
        if editMode == .active && unpickedItems.count != 0 && selection.filter({!$0.isPicked}).count != 0 {
            Button {
                withAnimation {
                    
                    showingClearAllConfirmation.toggle()
                }
            } label: {
                
                Label("Remove", systemImage: "trash")
            }
            .buttonStyle(SelecttionActionButton(color: .red.opacity(0.8)))
            .animation(.easeInOut, value: showingClearAllConfirmation)
            .alert(isPresented: $showingClearAllConfirmation, content: {
                
                Alert(title: Text("Remove selected"), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Ok"), action: deleteSelected))
            })
        }
    }
    
    //MARK: - History Button
    @ViewBuilder
    var backButton: some View {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack(spacing: 3) {
                    
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.mint)
                    Text("Back")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.mint)
                        .textCase(.none)
                }
            }
    }
    
    
    //MARK: - Menu View
    var menuView: some View {
        Group {
            if editMode == .inactive {
                Menu {
                    
                    editButton
                    Button {
                        withAnimation {
                            
                            isShowingAllItemsView = true
                        }
                    } label: {
                        
                        Label("Find Items", systemImage: "list.bullet.rectangle.portrait")
                    }
                } label: {
                    
                    Image(systemName: "ellipsis.circle")
                }
            } else {
                
                EditButton()
            }
        }
    }
    
    
    //MARK: - Edit Button
    var editButton: some View {
        if editMode == .inactive {
            return Button {
                
                editMode = .active
            } label: {
                
                Label("Edit", systemImage: "square.and.pencil")
            }
        } else {
            return Button {
                
                editMode = .inactive
            } label: {
                
                Label("Done", systemImage: "")
            }
        }
    }
    
    
    
    //MARK: - Fetch Results
    var textFieldResults: [Item] {
        var suggestedItems: Array<Item> = []
        suggestedItems = Array(items)

        ckItems.forEach { listItem in
            suggestedItems.removeAll(where: {$0.nameDisplay.contains(listItem.name ?? "")})
        }
        
        return suggestedItems.filter({$0.nameDisplay.localizedCaseInsensitiveContains(nameText)}).sorted(by: {$0.nameDisplay.lowercased() < $1.nameDisplay.lowercased()})
    }
    
    var unpickedItems: [CKItem] {
        ckItems.filter({!$0.isPicked}).sorted(by: {$0.order < $1.order})
    }
    
    var pickedItems: [CKItem] {
        ckItems.filter({$0.isPicked}).sorted(by: {$0.order < $1.order})
    }
    
    var nonDuplicate: [Array<Any>] {
        [ckItems.filter({$0.name != nameText}), items.filter({$0.nameDisplay != nameText})]
    }
    
    var duplicateInUse: [CKItem] {
        ckItems.filter({$0.name == nameText})
    }
    
    var duplicateNotInUse: [Item] {
        items.filter({$0.nameDisplay == nameText})
    }
    
    //MARK: - Functions
    private func addItem() {
        
        let canCreate = persistenceController.fullVersionUnlocked || persistenceController.count(for: Item.fetchRequest()) < 10
        if canCreate {
            withAnimation {
                let newListItem = ListItem(context: viewContext)
                newListItem.id = UUID()
                newListItem.name = nameText
                newListItem.quantity = 1
                newListItem.order = Int16(unpickedItems.count + 1)
                newListItem.isPicked = false
                newListItem.lastModified = Date()
                newListItem.timestamp = Date()
//                newListItem.list = list
                
                let newItem = Item(context: viewContext)
                newItem.id = UUID()
                newItem.name = nameText
                newItem.quantity = 1
                newItem.order = Int16(unpickedItems.count + 1)
                newItem.isInUse = false
                newItem.isPicked = false
                newItem.lastModified = Date()
                newItem.timestamp = Date()
                                
                    try? viewContext.save()
//                persistenceController.update(newItem)
//                sharedItemRepo.addItem(name: nameText, timestamp: Date(), isInUse: true, isPicked: false, isUrgent: false, lastModified: Date(), order: Int64(unpickedItems.count + 1), quantity: 1){ _ in
//                        isAddingList = true
//                }
                nameText = ""
            }
        } else {
            nameIsFocused = false
            hideKeyboard()
            nameText = ""
            isShowingUnlockView.toggle()
        }
    }
    
//    private func removeFromList(_ item: CKItem) {
//        withAnimation {
//            viewContext.perform {
//                viewContext.delete(item)
//
////            var urlsToDelete = [URL]()
////            audioRecorder.recordings.filter({$0.fileURL.absoluteString.contains(item.id!.uuidString)}).forEach { recording in
////                urlsToDelete.append(recording.fileURL)
////            }
//
//                do {
////                audioRecorder.deleteRecording(urlsToDelete: urlsToDelete)
//                    try viewContext.save()
//                } catch {
//                    let nsError = error as NSError
//                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                }
//            }
//        }
//    }
    
    private func addToList(_ item: Item) {
        withAnimation {
            if persistenceController.fullVersionUnlocked {
                let newItem = ListItem(context: viewContext)
                newItem.id = UUID()
                newItem.name = item.name
                newItem.image = item.image
                newItem.quantity = 1
                newItem.order = Int16(unpickedItems.count + 1)
                newItem.isPicked = false
                newItem.lastModified = Date()
                newItem.timestamp = Date()
//                newItem.list = list
                        
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
                nameText = ""

            }
        }
    }
    
    func unselectAll() {
        if editMode == .inactive {
            selection.removeAll()
        }
    }
    
    private func deleteSelected() {
        for item in selection {
            withAnimation {
                
                viewContext.delete(item)
            }
        }
        selection = Set<ListItem>()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
//    private func move( from source: IndexSet, to destination: Int) {
//        // Make an array of items from fetched results
//        var revisedItems: [ CKItem ] = unpickedItems.map{ $0 }
//        
//        // change the order of the items in the array
//        revisedItems.move(fromOffsets: source, toOffset: destination )
//        
//        // update the userOrder attribute in revisedItems to
//        // persist the new order. This is done in reverse order
//        // to minimize changes to the indices.
//        for reverseIndex in stride( from: revisedItems.count - 1,
//                                    through: 0,
//                                    by: -1 )
//        {
//            revisedItems[ reverseIndex ].order =
//                Int64( reverseIndex )
//        }
//        do {
//            try viewContext.save()
//        } catch {
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//    }
    
    func openURL(_ url: URL) {
        nameIsFocused = true
    }
    
    func addItemFromShortcut( _ userActivity: NSUserActivity) {
        nameIsFocused = true
    }
    
    func fetchSharedItems(list: CKList) {
        guard itemsLoadState == .inactive else { return }
        itemsLoadState = .loading
        
        let recordID = CKRecord.ID(recordName: list.id)
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let pred = NSPredicate(format: "list == %@", reference)
        let sort = NSSortDescriptor(key: "order", ascending: true)
        let query = CKQuery(recordType: Config.itemRecord, predicate: pred)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
//        operation.desiredKeys = ["name", "isPicked", "isUrgent", "lastModified", "order", "quantity", "timestamp"]
        
        operation.recordFetchedBlock = { record in
            let id = record.recordID.recordName
            let name = record["name"] as? String ?? "No title"
            let isPicked = record["isPicked"] as? Bool ?? false
            let isUrgent = record["isUrgent"] as? Bool ?? false
            let lastModified = record["lastModified"] as? Date ?? Date()
            let order = record["order"] as? Int64 ?? 0
            let quantity = record["quantity"] as? Int64 ?? 1
            let timestamp = record["timestamp"] as? Date ?? Date()

            let sharedItem = CKItem(id: id, isPicked: isPicked, isUrgent: isUrgent, lastModified: lastModified, name: name, order: order, quantity: quantity, timestamp: timestamp)
            ckItems.append(sharedItem)
            itemsLoadState = .success
        }

        operation.queryCompletionBlock = { _, _ in
            if items.isEmpty {
                itemsLoadState = .noResults
            }
        }
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
}

//struct SharedListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SharedListView()
//    }
//}
