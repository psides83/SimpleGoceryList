//
//  Persistence.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/10/21.
//

import CoreData
import CloudKit
#if !os(watchOS)
import CoreSpotlight
#endif
import StoreKit
import SwiftUI

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    static var preview: PersistenceController = {
        let result = PersistenceController()
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
        
    /// The UserDefaults suite where we're saving user data.
    let defaults: UserDefaults
    
    /// Loads and saves whether our premium unlock has been purchased.
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }
        
        set {
            defaults.setValue(newValue, forKey: "fullVersionUnlocked")
        }
    }

    let container: NSPersistentCloudKitContainer
    let storeURL: URL
    let storeDescription: NSPersistentStoreDescription


    init(defaults: UserDefaults = .standard) {
        
        self.defaults = defaults

        storeURL = URL.storeURL(for: Config.appGroupIDID, databaseName: Config.database)
        container = NSPersistentCloudKitContainer(name: Config.database)
        storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Config.containerID)

        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSObject, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
    }
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    #if os(iOS)
    func update(_ item: Item) {
        let itemID = item.objectID.uriRepresentation().absoluteString

        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = item.name

        let searchableItem = CSSearchableItem(
            uniqueIdentifier: itemID,
            domainIdentifier: itemID,
            attributeSet: attributeSet
        )

        CSSearchableIndex.default().indexSearchableItems([searchableItem])

        try? container.viewContext.save()
    }
    
    func update(_ list: ItemList) {
        let listID = list.objectID.uriRepresentation().absoluteString

        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = list.title

        let searchableList = CSSearchableItem(
            uniqueIdentifier: listID,
            domainIdentifier: listID,
            attributeSet: attributeSet
        )

        CSSearchableIndex.default().indexSearchableItems([searchableList])

        try? container.viewContext.save()
    }
    
    func item(with uniqueIdentifier: String) -> Item? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Item
    }
    
    func delete(_ object: NSManagedObject) {
        let id = object.objectID.uriRepresentation().absoluteString

        if object is Item {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
        } else {
            CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
        }

        container.viewContext.delete(object)
    }
    
    func appLaunched() {
        @AppStorage("appLaunches") var appLaunches: Int = 0
        
        guard appLaunches < 26 else { return }
        
        appLaunches += 1
        print("appLaunches = \(appLaunches)")
        
        guard appLaunches == 25 else { return }
        
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive}
        
        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    #endif
}

public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
