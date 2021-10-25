//
//  File.swift
//  iOS15 Features
//
//  Created by Payton Sides on 6/8/21.
//

import CloudKit
import CoreData
import Foundation
import SwiftUI

extension Item {
    
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
        if isInUse && !isPicked {
            return true
        } else {
            return false
        }
    }
    
    static var example: Item {
        let controller = PersistenceController()
        let viewContext = controller.container.viewContext

        let item = Item(context: viewContext)
        item.name = "Example Item"
        item.quantity = 1
        item.isInUse = true
        item.isPicked = false
        item.lastModified = Date()
        return item
    }
}
