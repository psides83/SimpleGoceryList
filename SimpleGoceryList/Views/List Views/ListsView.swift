//
//  ListsView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 7/13/21.
//

import CloudKit
import SwiftUI

struct ListsView: View {
    static let tag: String? = "Lists"
    
    //MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    @EnvironmentObject var persistenceController: PersistenceController
    //    @EnvironmentObject private var sharedItemRepo: SharedItemRepo
    
    @FetchRequest(
        entity: ItemList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemList.timestamp, ascending: true)],
        animation: .default)
    private var lists: FetchedResults<ItemList>
    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    
    @State private var ckLists = [CKList]()
    @State private var loadState = LoadState.inactive
    @State private var ckItems = [CKItem]()
    @State private var itemsLoadState = LoadState.inactive
    
    @State private var titleText = ""
    @Binding var titleIsFocused: Bool
    @State private var showingDuplicateToast = false
    @State private var isShowingUnlockView = false
    @State private var isAddingList = false
    @Binding var isShowingAddListView: Bool
    @State private var isShowingList = false
    @State private var isShowingQuickList = false
    @State private var editMode: EditMode = .inactive
    @State private var selectedList: ItemList? = nil
    @State private var selectedCKList: CKList? = nil
    @State private var isShowingCKList = false
    @State private var currentList: ItemList?
    let width = UIScreen.main.bounds.width / 2.75
    let height = UIScreen.main.bounds.height / 7
    
    var body: some View {
        ZStack {
            VStack {
                
                scrollView
                    .fullScreenCover(item: $selectedCKList) { list in
                        SharedListView(ckList: list)
                    }
//                    .toolbar(content: {
//                        ToolbarItem {
//                            Button
//                        }
//                    })
            }
//            .onAppear {
//                fetchSharedLists()
//            }
            .fullScreenCover(item: $selectedList) { list in
                ListView(list: list)
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .disabled(isShowingAddListView)
            .blur(radius: isShowingAddListView ? 4 : 0)
            
            addListView
        }
    }
    
    //MARK: - Scroll View
    var scrollView: some View {
        ScrollView {
            LazyVGrid(columns: columns, content: {
                
                quickListBox
                    .padding(.bottom)
                    .fullScreenCover(isPresented: $isShowingQuickList) {
                        QuickListView(audioRecorder: AudioRecorder(), editMode: $editMode)
                    }
                
                ForEach(lists) { list in
                    
                    listBox(list)
                        .padding(.bottom)
//                    ckList(list: list)
//                        .padding(.bottom)
//                        .onAppear {
//                            fetchSharedItems(list: list)
//                        }
                    //                        .onDrag({
                    //
                    //                            currentList = list
                    //
                    //                            return NSItemProvider(contentsOf: URL(string: "\(String(describing: list.id?.uuidString))"))!
                    //                        })
                    //                        .onDrop(of: [.url], delegate: DropViewDelegate(list: list, listData: Array(lists), currentList: currentList ?? list))
                }
            })
            .padding()
            .padding(.top, 6)
        }
    }
    
    //MARK: - Add Item TextField
    var inputTextField: some View {
        VStack {
            
            CustomTextField("add list", text: $titleText, isEditing: $titleIsFocused)
                .autocapitalization(.words)
                .returnKeyType(.done)
                .onReturn {
                    if titleText.isEmpty {
                        
                        hideKeyboard()
                    } else {
                        if duplicateList.count != 0 {
                            
                            showingDuplicateToast = true
                            titleText = ""
                            titleIsFocused = true
                        } else {
                            
                            addList()
                            titleIsFocused = true
                            isShowingAddListView = false
                        }
                    }
                }
                .showsClearButton(titleIsFocused)
                .onClear {
                    
                    titleIsFocused = false
                    titleText = ""
                    hideKeyboard()
                }
        }
    }
    
    //MARK: - List Box
    @ViewBuilder
    func listBox(_ list: ItemList) -> some View {
        VStack(alignment: .leading) {
            Button {
                selectedList = list
                isShowingList.toggle()
            } label: {
                HStack {
                    Text(list.titleDisplay)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.orangeLight)
                    Spacer()
                    if list.items == nil {
                        Text("0")
                            .font(.title2.weight(.heavy))
                            .foregroundColor(.mint)
                    } else {
                        Text(list.items!.count.string)
                            .font(.title2.weight(.heavy))
                            .foregroundColor(.mint)
                    }
                }
                .padding(.leading)
                .padding(.trailing)
                .padding(.top, 10)
                .padding(.bottom, 6)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            HStack {
                Button {
                    selectedList = list
                    isShowingList.toggle()
                } label: {
                    VStack(alignment: .leading) {
                        ForEach(list.listItems.prefix(6), id: \.self) { item in
                            Text(item.nameDisplay)
                                .font(.caption2)
                                .foregroundColor(.picked)
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Spacer()
                VStack {
                    Spacer()
                    Menu {
                        Button {
                            delete(list)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .imageScale(.small)
                    }
                    .accentColor(.mint)
                    .padding(12)
                }
            }
        }
        .frame(minWidth: width, minHeight: height)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
        )
    }
    
    //MARK: - Quick List Box
    @ViewBuilder
    var quickListBox: some View {
        VStack(alignment: .leading) {
            Button {
                isShowingQuickList = true
            } label: {
                HStack {
                    Text("Quick List")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.orangeLight)
                    Spacer()
                    Text(quickListCount)
                        .font(.title2.weight(.heavy))
                        .foregroundColor(.mint)
                }
                .padding(.leading)
                .padding(.trailing)
                .padding(.top, 10)
                .padding(.bottom, 6)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            Button {
                isShowingQuickList = true
            } label: {
                VStack(alignment: .leading) {
                    ForEach(quickList, id: \.self) { item in
                        Text(item.nameDisplay)
                            .font(.caption2)
                            .foregroundColor(.picked)
                    }
                }
                .padding(.leading)
                .padding(.trailing, 10)
                .padding(.bottom, 10)
                Spacer()
            }
            .buttonStyle(BorderlessButtonStyle())
            
            Spacer()
        }
        .frame(minWidth: width, minHeight: height)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
        )
    }
    
    //MARK: - Add List View
    @ViewBuilder var addListView: some View {
        if isShowingAddListView {
            VStack {
                Text("Add List")
                    .font(.title.weight(.bold))
                    .foregroundColor(.orangeLight)
                
                inputTextField
                    .padding(10)
                    .background(Color.systemGroupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                
                HStack {
                    Button {
                        isShowingAddListView.toggle()
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.mint)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                    
                    Button {
                        if duplicateList.count != 0 {
                            
                            showingDuplicateToast = true
                            titleText = ""
                            titleIsFocused = true
                        } else {
                            
                            addList()
                            isShowingAddListView = false
                        }
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.mint)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                }
            }
            .padding()
            .background(Color.secondarySystemGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.3), radius: 3, x: 3, y: 3)
            .padding()
            .transition(.scale.animation(Animation.easeInOut(duration: 0.15)))
        }
    }
    
    //MARK: - CK List View
//    func ckList(list: CKList) -> some View {
////            NavigationView {
//        Group {
//            switch loadState {
//            case .inactive, .loading:
//                ProgressView()
//            case .noResults:
//                Text("No results")
//            case .success:
//                VStack(alignment: .leading) {
//                    Button {
//                        selectedCKList = list
//                        isShowingCKList.toggle()
//                    } label: {
//                        HStack {
//                            Text(list.title)
//                                .font(.title3.weight(.bold))
//                                .foregroundColor(.orangeLight)
//                            Spacer()
//                            Text(ckItems.count.string)
//                                .font(.title2.weight(.heavy))
//                                .foregroundColor(.mint)
//                        }
//                        .padding(.leading)
//                        .padding(.trailing)
//                        .padding(.top, 10)
//                        .padding(.bottom, 6)
//                    }
//                    .buttonStyle(BorderlessButtonStyle())
//
//                    HStack {
//                        Button {
//                            selectedCKList = list
//                            isShowingCKList.toggle()
//                        } label: {
//                            VStack(alignment: .leading) {
//                                ForEach(ckItems.prefix(6)) { item in
//                                    Text(item.name ?? "")
//                                        .font(.caption2)
//                                        .foregroundColor(.picked)
//                                }
//                                Spacer()
//                            }
//                            .padding(.leading)
//                            .padding(.trailing, 10)
//                            .padding(.bottom, 10)
//                        }
//                        .buttonStyle(BorderlessButtonStyle())
//
//                        Spacer()
//                        VStack {
//                            Spacer()
//                            Menu {
//                                Button {
////                                            delete(list)
//                                } label: {
//                                    Label("Delete", systemImage: "trash")
//                                }
//                            } label: {
//                                Image(systemName: "ellipsis")
//                                    .imageScale(.small)
//                            }
//                            .accentColor(.mint)
//                            .padding(12)
//                        }
//                    }
//                }
//                .frame(minWidth: width, minHeight: height)
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color.white)
//                        .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
//                )
//            }
//        }
//    }
    
//    func fetchSharedLists() {
//        guard loadState == .inactive else { return }
//        loadState = .loading
//
//        let pred = NSPredicate(value: true)
//        let sort = NSSortDescriptor(key: "timestamp", ascending: false)
//        let query = CKQuery(recordType: Config.itemListRecord, predicate: pred)
//        query.sortDescriptors = [sort]
//
//        let operation = CKQueryOperation(query: query)
////        operation.desiredKeys = ["title", "timestamp"]
////        operation.resultsLimit = 50
//
//        operation.recordFetchedBlock = { record in
//            let id = record.recordID.recordName
//            let title = record["title"] as? String ?? "No title"
//            let timestamp = record["timestamp"] as? Date ?? Date()
////            let items = record["items"] as? [CKItem] ?? []
//
//
//            let sharedList = CKList(id: id, title: title, timestamp: timestamp)
//            ckLists.append(sharedList)
//            loadState = .success
//        }
//
//        operation.queryCompletionBlock = { _, _ in
//            if ckLists.isEmpty {
//                loadState = .noResults
//            }
//        }
//
//        CKContainer.default().privateCloudDatabase.add(operation)
//    }
    
//    func fetchSharedItems(list: CKList) {
//        guard itemsLoadState == .inactive else { return }
//        itemsLoadState = .loading
//
//        let recordID = CKRecord.ID(recordName: list.id)
//        let reference = CKRecord.Reference(recordID: recordID, action: .none)
//        let pred = NSPredicate(format: "list == %@", reference)
//        let sort = NSSortDescriptor(key: "order", ascending: true)
//        let query = CKQuery(recordType: Config.itemRecord, predicate: pred)
//        query.sortDescriptors = [sort]
//
//        let operation = CKQueryOperation(query: query)
////        operation.desiredKeys = ["name", "isPicked", "isUrgent", "lastModified", "order", "quantity", "timestamp"]
//
//        operation.recordFetchedBlock = { record in
//            let id = record.recordID.recordName
//            let name = record["name"] as? String ?? "No title"
//            let isPicked = record["isPicked"] as? Bool ?? false
//            let isUrgent = record["isUrgent"] as? Bool ?? false
//            let lastModified = record["lastModified"] as? Date ?? Date()
//            let order = record["order"] as? Int64 ?? 0
//            let quantity = record["quantity"] as? Int64 ?? 1
//            let timestamp = record["timestamp"] as? Date ?? Date()
//
//            let sharedItem = CKItem(id: id, isPicked: isPicked, isUrgent: isUrgent, lastModified: lastModified, name: name, order: order, quantity: quantity, timestamp: timestamp)
//            ckItems.append(sharedItem)
//            itemsLoadState = .success
//        }
//
//        operation.queryCompletionBlock = { _, _ in
//            if items.isEmpty {
//                itemsLoadState = .noResults
//            }
//        }
//
//        CKContainer.default().privateCloudDatabase.add(operation)
//    }
    
    //MARK: - Computed Properties
    var quickListCount: String {
        items.filter({$0.isInUse}).count.string
    }
    
    var quickList: ArraySlice<Item> {
        items.filter({$0.isInUse}).prefix(6)
    }
    
    //MARK: - Functions
    private func addList() {
        
        let canCreate = persistenceController.fullVersionUnlocked || persistenceController.count(for: ItemList.fetchRequest()) < 10
        if canCreate {
            withAnimation {
                let newList = ItemList(context: viewContext)
                newList.id = UUID()
                newList.title = titleText
                newList.timestamp = Date()
                
                //                persistenceController.update(newList)
                SharedItemRepo().addList(title: titleText, timestamp: Date(), list: newList) { _ in
                    isAddingList = true
                }
                titleText = ""
            }
        } else {
            titleIsFocused = false
            hideKeyboard()
            titleText = ""
            isShowingUnlockView.toggle()
        }
    }
    
    private func delete(_ item: ItemList) {
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
    
    var duplicateList: [ItemList] {
        lists.filter({$0.title == titleText})
    }
}

//struct ListsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListsView()
//    }
//}
