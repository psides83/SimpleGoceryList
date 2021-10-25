//
//  ListIconView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/13/21.
//

import SwiftUI

struct ListIconView: View {
    
    //MARK: - Properties
    var backgroundColor: Color
    var circleColor: Color
    var lineColor: Color
    var topCircleIcon: String
    var bottomCircleIcon: String
    var scale: CGFloat
    
    //MARK: - Body
    var body: some View {
        VStack {
            HStack {
                VStack(spacing: -1) {
                    HStack(spacing: 2 * scale) {
                        Image(systemName: topCircleIcon)
                            .font(.system(size: 10 * scale).weight(.heavy))
                            .foregroundColor(circleColor)
                        Image(systemName: "line.diagonal")
                            .font(.system(size: 14 * scale).weight(.heavy))
                            .foregroundColor(lineColor)
                            .rotationEffect(Angle(degrees: 45))
                    }
                    HStack(spacing: 2 * scale) {
                        Image(systemName: bottomCircleIcon)
                            .font(.system(size: 10 * scale).weight(.heavy))
                            .foregroundColor(circleColor)
                        Image(systemName: "line.diagonal")
                            .font(.system(size: 14 * scale).weight(.heavy))
                            .foregroundColor(lineColor)
                            .rotationEffect(Angle(degrees: 45))
                    }
                }
                .padding(.leading, 6 * scale)
                .padding(.trailing, 6 * scale)
                .padding(.top, 4 * scale)
                .padding(.bottom, 4 * scale)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: scale == 1 ? 8 : 10))
                .shadow(color: .black.opacity(0.2), radius: 2 * scale, x: 1 * scale, y: 1 * scale)
            }
        }
    }
}

//MARK: - Preview
struct ListIconView_Previews: PreviewProvider {
    static var previews: some View {
        ListIconView(backgroundColor: .mint, circleColor: .white, lineColor: .secondary.opacity(0.6), topCircleIcon: "circle", bottomCircleIcon: "checkmark.circle.fill", scale: 1)
    }
}
