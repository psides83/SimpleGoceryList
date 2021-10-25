//
//  TabBarButtonView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/15/21.
//

import SwiftUI

struct TabBarButtonView: View {
    
    //MARK: - Properties
    @Binding var current : String
    var image : String
    var animation : Namespace.ID
    
    //MARK: - Body
    var body: some View {

        Button(action: {
            withAnimation{current = image}
        }) {
            
            VStack(spacing: 5){
                
                Image(systemName: image)
                    .font(.title2)
                    .foregroundColor(current == image ? .mint : Color.black.opacity(0.3))
                // default Frame to avoid resizing...
                    .frame(height: 35)
                
                ZStack{
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 4)
                    
                    // matched geometry effect slide animation...
                    
                    if current == image{
                        
                        Rectangle()
                            .fill(Color.orange.opacity(0.6))
                            .frame(height: 4)
                            .matchedGeometryEffect(id: "Tab", in: animation)
                    }
                }
            }
        }
    }
}
