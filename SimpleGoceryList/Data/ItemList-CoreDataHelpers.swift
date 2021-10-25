//
//  ItemList-CoreDataHelpers.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 7/13/21.
//

import CloudKit
import CoreData
import Foundation
import SwiftUI

extension ItemList {
    //MARK: - Wrapped Properties
    var titleDisplay: String {
        title ?? ""
    }
    
    enum colors {
        
    }
    
    var listItems: [ListItem] {
        let itemsArray = items?.allObjects as? [ListItem] ?? []

        return itemsArray
    }
    
    var unpickedItems: [ListItem] {
        let itemsArray = items?.allObjects as? [ListItem] ?? []

        
            return itemsArray.filter({!$0.isPicked}).sorted(by: {$0.order < $1.order})
    }
    
    var pickedItems: [ListItem] {
        let itemsArray = items?.allObjects as? [ListItem] ?? []

            return itemsArray.filter({$0.isPicked}).sorted(by: {$0.order < $1.order})
    }
    
    func prepareCDToCKRecords(zoneID: CKRecordZone.ID) -> [CKRecord] {
//        let parentName = objectID.uriRepresentation().absoluteString
        let parentID = CKRecord.ID(zoneID: zoneID)
        let parent = CKRecord(recordType: Config.itemListRecord, recordID: parentID)
        parent["title"] = titleDisplay
        parent["id"] = id?.uuidString
        parent["timestamp"] = timestamp
        
        var records = listItems.map { item -> CKRecord in
            let childName = item.objectID.uriRepresentation().absoluteString
            let childID = CKRecord.ID(recordName: childName)
            let child = CKRecord(recordType: Config.itemRecord, recordID: childID)
            child["name"] = item.nameDisplay
            child["image"] = item.image
            child["isPicked"] = item.isPicked
            child["isUrgent"] = item.isUrgent
            child["lastModified"] = item.lastModified
            child["order"] = item.order
            child["quantity"] = item.quantity
            child["tiemstamp"] = item.timestamp
            child["list"] = CKRecord.Reference(recordID: parentID, action: .deleteSelf)
            return child
        }
        
        records.append(parent)
        return records
    }
}
