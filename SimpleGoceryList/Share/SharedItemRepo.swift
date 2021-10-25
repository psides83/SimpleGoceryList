//
//  CKRepository.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 7/12/21.
//

import Foundation
import SwiftUI
import OSLog
import CloudKit


struct CKList: Identifiable {
    let id: String
    let title: String
    let timestamp: Date
//    let items: [CKItem]
//    let associatedRecord: CKRecord
}

extension CKList {
    
    init?(record: CKRecord) {
    guard let title = record["title"] as? String,
          let timestamp = record["timestamp"] as? Date
//          let items = record["items"] as? [CKItem]
    else { return nil }
    
        self.id = record.recordID.recordName
        self.title = title
        self.timestamp = timestamp
//        self.items = items
//        self.associatedRecord = record
    }
}

struct CKItem: Identifiable {
//    var audioFilename: String?
    let id: String
//    var image: Data?
//    let isInUse: Bool
    let isPicked: Bool
    let isUrgent: Bool
    let lastModified: Date?
    let name: String?
    let order: Int64
    let quantity: Int64
    let timestamp: Date?
//    let list: CKRecord.Reference
//    let associatedRecord: CKRecord
}

extension CKItem {
    /// Initializes a `CKItem` object from a CloudKit record.
    /// - Parameter record: CloudKit record to pull values from.
    init?(record: CKRecord) {
        guard let name = record["name"] as? String,
              let timestamp = record["timestamp"] as? Date,
//              let isInUse = record["isInUse"] as? Bool,
              let isPicked = record["isPicked"] as? Bool,
              let isUrgent = record["isUrgent"] as? Bool,
              let lastModified = record["lastModified"] as? Date,
              let order = record["order"] as? Int64,
              let quantity = record["quantity"] as? Int64
//              let list = record["list"] as? CKRecord.Reference
        else { return nil }

        self.id = record.recordID.recordName
        self.name = name
        self.timestamp = timestamp
//        self.isInUse = isInUse
        self.isPicked = isPicked
        self.isUrgent = isUrgent
        self.lastModified = lastModified
        self.order = order
        self.quantity = quantity
//        self.list = list
//        self.associatedRecord = record
    }
    
    var pickedImage: String {
        switch isPicked {
        case true: return "checkmark.circle.fill"
        case false: return "circle"
        }
    }
}

enum LoadState {
    case inactive, loading, success, noResults
}

class SharedItemRepo: ObservableObject {
    // MARK: - State

    enum State {
        case loading
        case loaded(private: [CKList], shared: [CKList])
        case error(Error)
    }

    // MARK: - Properties

    /// State directly observable by our view.
    @Published private(set) var state: State
    /// Use the specified iCloud container ID, which should also be present in the entitlements file.
    lazy var container = CKContainer(identifier: Config.containerID)
    /// This project uses the user's private database.
    private lazy var database = container.privateCloudDatabase
    /// Sharing requires using a custom record zone.
    let recordZone = CKRecordZone(zoneName: Config.itemListRecord)

    // MARK: - Init

    /// Initializer to provide explicit state (e.g. for previews).
    init(state: State = .loading) {
        self.state = state
    }

    // MARK: - API

    /// Creates custom zone if needed and performs initial fetch afterwards.
    func initialize(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        createZoneIfNeeded { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self.state = .error(error)
                    completionHandler?(.failure(error))

                case .success:
                    self.refresh()
                    completionHandler?(.success(()))
                }
            }
        }
    }

    /// Fetches items from the remote databases and updates local state.
    func refresh() {
        state = .loading

        fetchPrivateAndSharedItems { result in
            switch result {
            case let .success((privateItems, sharedItems)):
                self.state = .loaded(private: privateItems, shared: sharedItems)
            case let .failure(error):
                self.state = .error(error)
            }
        }
    }

    /// Fetch private and shared Items from iCloud databases.
    /// - Parameter completionHandler: Handler to process Item results or error.
    func fetchPrivateAndSharedItems(
        completionHandler: @escaping (Result<([CKList], [CKList]), Error>) -> Void
    ) {
        // Multiple operations are run asynchronously, storing results as they complete.
        var privateItems: [CKList]?
        var sharedItems: [CKList]?
        var lastError: Error?

        let group = DispatchGroup()

        group.enter()
        fetchLists(scope: .private, in: [recordZone]) { result in
            switch result {
            case .success(let items):
                privateItems = items
            case .failure(let error):
                lastError = error
            }

            group.leave()
        }

        group.enter()
        fetchSharedItems { result in
            switch result {
            case .success(let items):
                sharedItems = items
            case .failure(let error):
                lastError = error
            }

            group.leave()
        }

        // When all asynchronous operations have completed, inform the completionHandler of the result.
        group.notify(queue: .main) {
            if let error = lastError {
                completionHandler(.failure(error))
            } else {
                let privateItems = privateItems ?? []
                let sharedItems = sharedItems ?? []
                completionHandler(.success((privateItems, sharedItems)))
            }
        }
    }

    /// Adds a new Item to the database.
    /// - Parameters:
    ///   - name: Name of the Item.
    ///   - phoneNumber: Phone number of the item.
    ///   - completionHandler: Handler to process success or error of the operation.
    func addItem(
        name: String?,
        timestamp: Date?,
        isPicked: Bool,
        isUrgent: Bool,
        lastModified: Date?,
        order: Int64,
        quantity: Int64,
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) {
        let id = CKRecord.ID(zoneID: recordZone.zoneID)
        let itemRecord = CKRecord(recordType: Config.itemRecord, recordID: id)
        itemRecord["name"] = name
        itemRecord["timestamp"] = timestamp
        itemRecord["isPicked"] = isPicked
        itemRecord["isUrgent"] = isUrgent
        itemRecord["lastModified"] = lastModified
        itemRecord["order"] = order
        itemRecord["quantity"] = quantity

        let saveOperation = CKModifyRecordsOperation(recordsToSave: [itemRecord])
        saveOperation.savePolicy = .changedKeys

        saveOperation.modifyRecordsCompletionBlock = { recordsSaved, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(.failure(error))
                    debugPrint("Error adding item: \(error)")
                } else {
                    completionHandler(.success(()))
                }
            }
        }

        database.add(saveOperation)
    }
    
    func addList(
        title: String?,
        timestamp: Date?,
        list: ItemList,
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) {
        let id = CKRecord.ID(recordName: list.objectID.uriRepresentation().absoluteString, zoneID: recordZone.zoneID)
        let listRecord = CKRecord(recordType: Config.itemListRecord, recordID: id)
        listRecord["title"] = title
        listRecord["timestamp"] = timestamp
        
        var records = list.listItems.map { item -> CKRecord in
//            let childName = item.objectID.uriRepresentation().absoluteString
            let childID = CKRecord.ID(recordName: item.objectID.uriRepresentation().absoluteString, zoneID: recordZone.zoneID)
            let child = CKRecord(recordType: Config.itemRecord, recordID: childID)
            child["name"] = item.nameDisplay
//            child["image"] = item.image
            child["isPicked"] = item.isPicked
            child["isUrgent"] = item.isUrgent
            child["lastModified"] = item.lastModified
            child["order"] = item.order
            child["quantity"] = item.quantity
            child["tiemstamp"] = item.timestamp
            child["list"] = CKRecord.Reference(recordID: id, action: .deleteSelf)
            return child
        }
        
        records.append(listRecord)
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: records)
        saveOperation.savePolicy = .changedKeys

        saveOperation.modifyRecordsCompletionBlock = { recordsSaved, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(.failure(error))
                    debugPrint("Error adding item: \(error)")
                } else {
                    completionHandler(.success(()))
                }
            }
        }

        database.add(saveOperation)
    }

    /// Creates a `CKShare` and saves it to the private database in preparation to share a Item with another user.
    /// - Parameters:
    ///   - item: Item to share.
    ///   - completionHandler: Handler to process a `success` or `failure` result.
//    func createShare(list: CKList, completionHandler: @escaping (Result<(CKShare, CKContainer), Error>) -> Void) {
//        let share = CKShare(rootRecord: list.associatedRecord)
//        share[CKShare.SystemFieldKey.title] = "List: \(list.title)"
//
//        let operation = CKModifyRecordsOperation(recordsToSave: [list.associatedRecord, share])
//        operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
//            if let error = error {
//                completionHandler(.failure(error))
//                debugPrint("Error saving CKShare: \(error)")
//            } else {
//                completionHandler(.success((share, self.container)))
//            }
//        }
//
//        database.add(operation)
//    }

    // MARK: - Private

    /// Asynchronously fetches item for a given set of zones in a given database scope.
    /// - Parameters:
    ///   - scope: Database scope to fetch from.
    ///   - zones: Record zones to fetch items from.
    ///   - completionHandler: Handler to process success or failure of operation.
    private func fetchLists(
        scope: CKDatabase.Scope,
        in zones: [CKRecordZone],
        completionHandler: @escaping (Result<[CKList], Error>) -> Void
    ) {
        let database = container.database(with: scope)
        let zoneIDs = zones.map { $0.zoneID }
        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: zoneIDs,
                                                          configurationsByRecordZoneID: [:])
        var lists: [CKList] = []

        operation.recordChangedBlock = { record in
            if record.recordType == Config.itemListRecord, let list = CKList(record: record) {
                lists.append(list)
            }
        }

        operation.fetchRecordZoneChangesCompletionBlock = { error in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(lists))
            }
        }

        database.add(operation)
    }

    /// Fetches all shared Items from all available record zones.
    /// - Parameter completionHandler: Handler to process success or failure.
    private func fetchSharedItems(completionHandler: @escaping (Result<[CKList], Error>) -> Void) {
        // The first step is to fetch all available record zones in user's shared database.
        container.sharedCloudDatabase.fetchAllRecordZones { zones, error in
            if let error = error {
                completionHandler(.failure(error))
            } else if let zones = zones, !zones.isEmpty {
                // Fetch all Items in the set of zones in the shared database.
                self.fetchLists(scope: .shared, in: zones, completionHandler: completionHandler)
            } else {
                // Zones nil or empty so no shared items.
                completionHandler(.success([]))
            }
        }
    }

    /// Creates the custom zone in use if needed.
    /// - Parameter completionHandler: An optional completion handler to track operation completion or errors.
    private func createZoneIfNeeded(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        // Avoid the operation if this has already been done.
        guard !UserDefaults.standard.bool(forKey: "isZoneCreated") else {
            completionHandler?(.success(()))
            return
        }

        let createZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [recordZone])
        createZoneOperation.modifyRecordZonesCompletionBlock = { _, _, error in
            if let error = error {
                debugPrint("Error: Failed to create custom zone: \(error)")
                completionHandler?(.failure(error))
            } else {
                DispatchQueue.main.async {
                    UserDefaults.standard.setValue(true, forKey: "isZoneCreated")
                    completionHandler?(.success(()))
                }
            }
        }

        database.add(createZoneOperation)
    }
}
