//
//  ListItem-CoreDataHelpers.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 7/14/21.
//

import CloudKit
import CoreData
import Foundation
import SwiftUI

extension ListItem {
    
    //MARK: - Wrapped Properties
    var nameDisplay: String {
        name ?? ""
    }
    
    var modifiedDisplay: String {
        lastModified?.medium ?? ""
    }
    
    var modifiedDateOnly: String {
        lastModified?.dateOnly ?? ""
    }
    
    var modified: Date {
        lastModified ?? Date()
    }
    
    //MARK: - Computed Properties
    var pickedImage: String {
        switch isPicked {
        case true: return "checkmark.circle.fill"
        case false: return "circle"
        }
    }
    
    var isUnpicked: Bool {
        if !isPicked {
            return true
        } else {
            return false
        }
    }
    
    static var example: ListItem {
        let controller = PersistenceController()
        let viewContext = controller.container.viewContext

        let item = ListItem(context: viewContext)
        item.name = "Example Item"
        item.quantity = 1
        item.isPicked = false
        item.lastModified = Date()
        return item
    }
}
