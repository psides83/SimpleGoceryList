//
//  AddView.swift
//  WatchSimpleGroceryList Extension
//
//  Created by Payton Sides on 6/29/21.
//

import SwiftUI

struct AddView: View {
    
    @State private var name = ""
    
    var body: some View {
        TextField("add item", text: $name)
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
