//
//  IntroView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/16/21.
//

import SwiftUI

struct IntroView: View {
    
    //MARK: - Properties
    @Binding var isShowingIntroPage: Bool
    
    @State private var backgroundColor: Color = .white
    @State private var circleColor: Color = .mint
    @State private var lineColor: Color = .picked
    @State private var circleIcon: String = "circle"
    @State private var checkCircleIcon: String = "checkmark.circle.fill"
    @State private var scale: CGFloat = 2
    @State private var isChecked = false
    @State private var isShowingIcon = false
    @State private var animationAmount: CGFloat = 0
    @State private var checkAnimationAmount: CGFloat = 0.75
    
    //MARK: - Body
    var body: some View {
        ZStack {
            Color.mint.ignoresSafeArea()
                .opacity(animationAmount <= 3 ? 1 : 0)
            
//            if isShowingIcon {
            VStack(alignment: .center) {
                icon
                    .scaleEffect(animationAmount)
            }
//            }
        }
        .onAppear {
//            isShowingIcon = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(Animation.easeIn(duration: 0.75)) {
                    animationAmount += 3
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    withAnimation(.interpolatingSpring(stiffness: 50, damping: 4)) {
                        isChecked = true
                        checkAnimationAmount = 2
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isShowingIntroPage = false
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Icon
    var icon: some View {
        VStack {
            HStack {
                VStack(spacing: -1) {
                    HStack(spacing: 2 * scale) {
                        Image(systemName: circleIcon)
                            .font(.system(size: 10 * scale).weight(.heavy))
                            .foregroundColor(circleColor)
                        Image(systemName: "line.diagonal")
                            .font(.system(size: 14 * scale).weight(.heavy))
                            .foregroundColor(lineColor)
                            .rotationEffect(Angle(degrees: 45))
                    }
                    HStack(spacing: 2 * scale) {
                        Image(systemName: isChecked ? checkCircleIcon : circleIcon)
                            .font(.system(size: 10 * scale).weight(.heavy))
                            .foregroundColor(circleColor)
                            .overlay(Circle()
                                        .stroke(Color.mint)
                                        .scaleEffect(checkAnimationAmount)
                                        .opacity(Double(1.75 - checkAnimationAmount))
                                        .animation(
                                            Animation.easeInOut(duration: 0.5)
                                        )
                            )
                            
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

//struct CellPopoverView_Previews: PreviewProvider {
//    static var previews: some View {
//        IntroView(isShowingIntroPage: <#Binding<Bool>#>)
//    }
//}
