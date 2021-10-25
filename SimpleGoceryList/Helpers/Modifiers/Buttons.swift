//
//  Buttons.swift
//  CustomerManager
//
//  Created by Payton Sides on 3/24/21.
//

import SwiftUI

struct Buttons: View {
    var backgroundColor: Color
    var circleColor: Color
    var lineColor: Color
    
    var body: some View {
        HStack {
            VStack(spacing: -1) {
                HStack(spacing: 2) {
                    Image(systemName: "circle")
                        .font(.caption.weight(.black))
                        .foregroundColor(circleColor)
                    Image(systemName: "line.diagonal")
                        .font(.headline.weight(.heavy))
                        .foregroundColor(lineColor)
                        .rotationEffect(Angle(degrees: 45))
                }
                HStack(spacing: 2) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.black))
                        .foregroundColor(circleColor)
                    Image(systemName: "line.diagonal")
                        .font(.headline.weight(.heavy))
                        .foregroundColor(lineColor)
                        .rotationEffect(Angle(degrees: 45))
                }
            }
            .padding(6)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        Buttons(backgroundColor: .orange.opacity(0.5), circleColor: .white, lineColor: .white)
    }
}

struct SelecttionActionButton: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .font(.subheadline.weight(.semibold))
            .textCase(.none)
            .foregroundColor(.white)
            .padding(5)
            .background(isPressed ? color.opacity(0.2) : color.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
            .padding(.trailing)
    }
}

struct CircleButton: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .font(.subheadline.weight(.semibold))
            .textCase(.none)
            .foregroundColor(.white)
            .padding(6)
            .background(isPressed ? color.opacity(0.2) : color.opacity(0.6))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
    }
}

struct ContactButton: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
//            .padding()
            .frame(width: 85, height: 60, alignment: .center)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .shadow(color: configuration.isPressed ? Color.white : Color.gray.opacity(0.4), radius: 3)
            .foregroundColor(.blue)
            .overlay(
                Color.black
                    .opacity(configuration.isPressed ? 0.3 : 0)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            )
    }
}

struct CloseButtonStyle: ButtonStyle {
//    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundColor(.secondary)
            .padding(.all, 8)
//            .background(Color.black.opacity(0.6))
            .clipShape(Circle())
    }
}

struct ClearBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(Color.systemGroupedBackground)
                    .cornerRadius(10)
            } else {
                shape
                    .fill(Color.clear)
                    .cornerRadius(10)
            }
        }
    }
}

struct ClearButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .contentShape(Circle())
            .frame(width: 36, height: 36)
            .background(
                ClearBackground(isHighlighted: configuration.isPressed, shape: Circle())
            )
//            .animation(.easeInOut)
    }
}

struct PurchaseButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .frame(minWidth: 200, minHeight: 44)
            .background(Color.mint)
            .clipShape(Capsule())
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
