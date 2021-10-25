//
//  SearchCellView.swift
//  iOS15 Features
//
//  Created by Payton Sides on 6/8/21.
//

import SwiftUI

struct SearchCellView: View {
    
    //MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var item: Item
    @ObservedObject var haptics = Haptics()
            
    @State private var favoriteColor: Color = .pink.opacity(0.7)
    
    //MARK: - Body
    var body: some View {
        HStack {
            Text(item.nameDisplay)
                .accentColor(.mint)
            
//            Spacer()
//            
//            Text("Last used \(item.modifiedDateOnly)")
//                .font(.caption)
//                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color.secondarySystemGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.top, 6)
        .padding(.bottom, 6)
    }
}


