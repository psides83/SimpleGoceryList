//
//  ListHeaderView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/13/21.
//

import SwiftUI

struct ListHeaderView: View {
    
    //MARK: - Properties
    var topCircleIcon: String
    var bottomCircleIcon: String
    var text: String
    var backgroundColor: Color
    var circleColor: Color
    var lineColor: Color
    var scale: CGFloat
    
    //MARK: - Body
    var body: some View {
        HStack(alignment: .bottom) {
            
//            ListIconView(backgroundColor: backgroundColor, circleColor: circleColor, lineColor: lineColor, topCircleIcon: topCircleIcon, bottomCircleIcon: bottomCircleIcon, scale: scale)

            Text(text)
                .textCase(.none)
                .font(.title3.bold())
                .foregroundColor(.orangeLight)
        }
    }
}

//MARK: - Preview
struct ListHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ListHeaderView(topCircleIcon: "circle", bottomCircleIcon: "checkmark.circle.fill", text: "Current List", backgroundColor: Color.mint, circleColor: .white, lineColor: .secondary.opacity(0.6), scale: 1)
    }
}
