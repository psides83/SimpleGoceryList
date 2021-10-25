//
//  DropViewDelegate.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 7/16/21.
//

import SwiftUI

struct DropViewDelegate: DropDelegate {
    
    var list: ItemList
    var listData: [ItemList]
    var currentList: ItemList
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    mutating func dropEntered(info: DropInfo) {
        let fromIndex = listData.firstIndex { (list) -> Bool in
            return list.id?.uuidString == currentList.id?.uuidString
        } ?? 0
        
        let toIndex = listData.firstIndex { (list) -> Bool in
            return list.id?.uuidString == self.list.id?.uuidString
        } ?? 0
        
        if fromIndex != toIndex {
            withAnimation(.default) {
                let fromPage = listData[fromIndex]
                listData[fromIndex] = listData[toIndex]
                listData[toIndex] = fromPage
            }
        }
    }
}
