//
//  QuickListView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/10/21.
//

import SwiftUI
import CloudKit
import CoreData
import Foundation
import AVFoundation
import CoreSpotlight

struct QuickListView: View {
//    static let tag: String? = "QuickList"
    
    //MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
//    @EnvironmentObject var persistenceController: PersistenceController
    @EnvironmentObject private var sharedItemRepo: SharedItemRepo
    
    private let newItemActivity = "PaytonSides.SimpleGoceryList.newItem"
    
    @ObservedObject var audioRecorder: AudioRecorder
    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @AppStorage("v2point3") var v2point3: Bool = true
    
    @State var selectedItem: Item?
    @State private var nameText = ""
    @State private var unpickedIcon = "circle"
    @State private var pickedIcon = "checkmark.circle.fill"
    @Binding var editMode: EditMode
    @State private var showingClearAllConfirmation = false
    @State private var showingClearPickedConfirmation = false
    @State private var isShowingAllItemsView = false
    @State private var showingDuplicateToast = false
    @State private var selection = Set<Item>()
    @State private var nameIsFocused = false
    @State private var isShowingIntroPage = true
    @State private var isShowingUnlockView = false
    @State private var dataState: DataState = .loaded
    
    @State private var isSharing = false
    @State private var isProcessingShare = false
    @State private var isAddingItem = false
    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    
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
                            
                            /// The section of picked items only shows if the array has at least one item
                            
                            /// Section of picked itens
                            pickedSection
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("Quick List")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarHidden(PersistenceController().fullVersionUnlocked ? false : true)
                    .navigationBarItems(leading: backButton, trailing: EditButton())
                    .environment(\.editMode, $editMode)
                    .onContinueUserActivity(newItemActivity, perform: addItemFromShortcut)
                    .userActivity(newItemActivity, { activity in
                        activity.title = "Add Item"
                        activity.isEligibleForPrediction = true
                    })
                    .onOpenURL(perform: openURL)
                    
                    if nameIsFocused && PersistenceController().fullVersionUnlocked {
                        searchList
                            .background(Color.systemGroupedBackground)
                    }
                    
//                    HStack {
//                        Button(action: {
//                            mergeCDToCK()
//                            
//                        }, label: {
//                            Text("Merge CloudKit")
//                        })
//                        
////                        Button(action: {shareContact(item)}, label: {
////                            /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
////                        })
//                    }
                }
                .onChange(of: editMode, perform: { value in
                    unselectAll()
                })
            }
//            .sheet(isPresented: $isShowingUnlockView, content: {
//                UnlockView()
//            })
            
            if showingDuplicateToast && !v2point3 {
                DuplicateToastView()
                    .scaleEffect()
                    .animation(.easeInOut(duration: 1), value: showingDuplicateToast)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                
                                showingDuplicateToast = false
                            }
                        }
                    }
            }
            
            
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
                        
                        if PersistenceController().fullVersionUnlocked {
                            
                            ListIconView(
                                backgroundColor: .mint,
                                circleColor: .white,
                                lineColor: .picked,
                                topCircleIcon: unpickedIcon,
                                bottomCircleIcon: unpickedIcon,
                                scale: 0.95
                            )
                            .padding(.leading)
                            .padding(.top, 8)
                        } else {
                            
                            ListHeaderView(
                                topCircleIcon: unpickedIcon,
                                bottomCircleIcon: unpickedIcon,
                                text: "Current List",
                                backgroundColor: .mint,
                                circleColor: .white,
                                lineColor: .picked,
                                scale: 1
                            )
                            .padding(.top, 3)
                        }
                        
                        Spacer()
                        
                        removeUnpickedButton
                    }
        ) {
            ForEach(unpickedItems, id: \.self) { item in
                ZStack {
                    
                    ItemCellView(item: item, editMode: $editMode)
                }
            }
            .onMove(perform: { indices, newOffset in
                
                move(from: indices, to: newOffset)
            })
            .onDelete { offsets in
                
                let allItems = unpickedItems
                
                for offset in offsets {
                    let item = allItems[offset]
                    removeFromList(item)
                }
            }
            
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
                        
                        if PersistenceController().fullVersionUnlocked {
                            
                            ListIconView(
                                backgroundColor: .picked,
                                circleColor: .mint,
                                lineColor: .white,
                                topCircleIcon: pickedIcon,
                                bottomCircleIcon: pickedIcon,
                                scale: 0.95
                            )
                            .padding(.leading)
                            .padding(.top, 8)
                        } else {
                            
                            ListHeaderView(
                                topCircleIcon: pickedIcon,
                                bottomCircleIcon: pickedIcon,
                                text: "Picked",
                                backgroundColor: .picked,
                                circleColor: .mint,
                                lineColor: .white,
                                scale: 1
                            )
                        }
                        
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
                                Alert(
                                    title: Text("Remove selected?"),
                                    primaryButton: .default(Text("Cancel")),
                                    secondaryButton: .destructive(Text("Ok"),
                                    action: clearSelected)
                                )
                            })
                        }
                    }
        ) {
            ForEach(pickedItems, id: \.self) { item in
                
                ItemCellView(item: item, editMode: $editMode)
            }
            .onDelete { offsets in
                let allItems = pickedItems
                
                for offset in offsets {
                    let item = allItems[offset]
                    removeFromList(item)
                }
            }
        }
    }
    
    //MARK: - Favorites Section
    var favoritesSection: some View {
        Section(header: Text("Favorites")) {
            ForEach(favorites) { item in
                
                ItemCellView(item: item, editMode: $editMode)
            }
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
        if editMode == .active && unpickedItems.count != 0 && selection.filter({!$0.isPicked && $0.isInUse}).count != 0 {
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
                
                Alert(title: Text("Remove selected"), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Ok"), action: clearSelected))
            })
        }
    }
    
    //MARK: - History Button
    @ViewBuilder
    var historyButton: some View {
        if PersistenceController().fullVersionUnlocked {
            Button {
                
                isShowingAllItemsView = true
                editMode = .inactive
            } label: {
                HStack(spacing: 3) {
                    
                    Image(systemName: "clock")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.orange.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Text("History")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.orange.opacity(0.7))
                        .textCase(.none)
                }
            }
            .fullScreenCover(isPresented: $isShowingAllItemsView, content: {
                AllItemsListView()
            })
        } else {
            Button {
                
                isShowingUnlockView = true
            } label: {
                HStack(spacing: 3) {
                    
                    Image(systemName: "clock")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.orange.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Text("History")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.orange.opacity(0.7))
                        .textCase(.none)
                }
            }
        }
    }
    
    //MARK: - Back Button
    var backButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Label("Back", systemImage: "chevron.left")
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
    
    //MARK: - Share View
    ///Builds a `CloudSharingView` with state after processing a share.
    private func shareView() -> CloudSharingView? {
        guard let share = activeShare, let container = activeContainer else {
            return nil
        }

        return CloudSharingView(container: container, share: share)
    }
    
    //MARK: - Fetch Results
    
    var unpickedItems: [Item] {
        withAnimation {
            items.filter({!$0.isPicked && $0.isInUse}).sorted(by: {$0.order < $1.order})
        }
    }
    
    var pickedItems: [Item] {
        withAnimation {
            items.filter({$0.isPicked && $0.isInUse}).sorted(by: {$0.order < $1.order})
        }
    }
    
    var favorites: [Item] {
        withAnimation {
            items.filter({$0.isFavorite && !$0.isPicked && !$0.isInUse}).sorted(by: {$0.modified > $1.modified})
        }
    }
    
    var textFieldResults: [Item] {
        withAnimation {
            items.filter({$0.nameDisplay.localizedCaseInsensitiveContains(nameText) && $0.isInUse == false}).sorted(by: {$0.nameDisplay.lowercased() < $1.nameDisplay.lowercased()})
        }
    }
    
    var nonDuplicate: [Item] {
        items.filter({$0.nameDisplay != nameText && !$0.isInUse})
    }
    
    var duplicateInUse: [Item] {
        items.filter({$0.nameDisplay == nameText && $0.isInUse})
    }
    
    var duplicateNotInUse: [Item] {
        items.filter({$0.nameDisplay == nameText && !$0.isInUse})
    }
    
    //MARK: - Functions
    private func addItem() {
        
        let canCreate = PersistenceController().fullVersionUnlocked || PersistenceController().count(for: Item.fetchRequest()) < 10
        if canCreate {
            withAnimation {
                let newItem = Item(context: viewContext)
                newItem.id = UUID()
                newItem.name = nameText
                newItem.quantity = 1
                newItem.order = Int16(unpickedItems.count + 1)
                newItem.isPicked = false
                newItem.isInUse = true
                newItem.lastModified = Date()
                newItem.timestamp = Date()
                
                PersistenceController().update(newItem)
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
    
    private func makeFavorite(_ item: Item) {
        withAnimation {
            
            item.isFavorite.toggle()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func selectItem(with identifier: String) {
        selectedItem = PersistenceController().item(with: identifier)
    }
    
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            selectItem(with: uniqueIdentifier)
        }
    }
    
    private func removeFromList(_ item: Item) {
        withAnimation {
            viewContext.perform {
                if PersistenceController().fullVersionUnlocked {
                    item.quantity = 1
                    item.isInUse = false
                    item.isPicked = false
                    item.isUrgent = false
                } else {
                    viewContext.delete(item)
                }
                
                //            var urlsToDelete = [URL]()
                //            audioRecorder.recordings.filter({$0.fileURL.absoluteString.contains(item.id!.uuidString)}).forEach { recording in
                //                urlsToDelete.append(recording.fileURL)
                //            }
                
                do {
                    //                audioRecorder.deleteRecording(urlsToDelete: urlsToDelete)
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
    
    private func addToList(_ item: Item) {
        withAnimation {
            if PersistenceController().fullVersionUnlocked {
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
    }
    
    func unselectAll() {
        if editMode == .inactive {
            selection.removeAll()
        }
    }
    
    private func clearSelected() {
        for item in selection {
            withAnimation {
                if PersistenceController().fullVersionUnlocked {
                    item.quantity = 1
                    item.isPicked = false
                    item.isInUse = false
                    item.isUrgent = false
                } else {
                    viewContext.delete(item)
                }
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
    
    private func move( from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [ Item ] = unpickedItems.map{ $0 }
        
        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination )
        
        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride( from: revisedItems.count - 1,
                                    through: 0,
                                    by: -1 )
        {
            revisedItems[ reverseIndex ].order =
                Int16( reverseIndex )
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func openURL(_ url: URL) {
        nameIsFocused = true
    }
    
    func addItemFromShortcut( _ userActivity: NSUserActivity) {
        nameIsFocused = true
    }
}

////MARK: - Preview
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        QuickListView(audioRecorder: AudioRecorder()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}

//MARK: - Duplicate Toast View
struct DuplicateToastView: View {
    var body: some View {
        VStack(alignment: .center) {
                Text("Item already")
                    .font(.title.weight(.bold))
                    .foregroundColor(.secondary)
                Text("on list")
                    .font(.title.weight(.bold))
                    .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10)
    }
}

enum DuplicateStatus: CaseIterable {
    case duplicateInUse
    case duplicateNotInUse
    case notDuplicate
}
