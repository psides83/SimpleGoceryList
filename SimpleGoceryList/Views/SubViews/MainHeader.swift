//
//  MainHeader.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/14/21.
//

import SwiftUI

struct MainHeader: View {
    
    //MARK: - Properties
    @State var top = UIApplication.shared.windows.first?.safeAreaInsets.top
    @State var current = "house.fill"
    @Namespace var animation
    
    @State var isHide = false
    
    //MARK: - Body
    var body: some View {
        
        VStack(spacing: 0){
            
            // App Bar....
            VStack(spacing: 15){
                
                // hiding...
                if !isHide{
                    
                    HStack(spacing: 12){
                        
                        Text("Picked")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.mint)
                        
                        Spacer(minLength: 0)
                        
                        Button(action: {}) {
                            
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.black.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {}) {
                            
                            Image(systemName: "message.fill")
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.black.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .offset(x: 0, y: -25)))
                    .padding(.horizontal)
                }
                
                // CUstom Tab Bar....
                HStack(spacing: 0){
                    
                    TabBarButtonView(current: $current, image: "house.fill", animation: animation)
                    TabBarButtonView(current: $current, image: "clock", animation: animation)
                }
            }
            .padding(.top, 45)
            .background(Color.white)
            
            // Content....
            scrollView
            
        }
        .background(Color.systemGroupedBackground)
        .ignoresSafeArea()
    }
    
    //MARK: - ScrollView
    var scrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                // geomtry reader for getting location values....
                GeometryReader { reader -> AnyView in
                    
                    let yAxis = reader.frame(in: .global).minY
                    
                    // logic simple if if goes below zero hide nav bar
                    // above zero show navbar...
                    if yAxis < 0 && !isHide{
                        
                        DispatchQueue.main.async {
                            withAnimation{isHide = true}
                        }
                    }
                    
                    if yAxis > 0 && isHide{
                        
                        DispatchQueue.main.async {
                            withAnimation{isHide = false}
                        }
                    }
                    
                    return AnyView(
                        Text("")
                            .frame(width: 0, height: 0)
                    )
                }
                .frame(width: 0, height: 0)
                
                VStack(spacing: 15) {
                    
                    ForEach(1...20,id: \.self) { i in
                        
                        VStack(spacing: 10) {
                            
                            HStack(spacing: 10) {
                                
                                ListIconView(backgroundColor: .mint, circleColor: .white, lineColor: .picked, topCircleIcon: "checkmark.circle.fill", bottomCircleIcon: "checkmark.circle.fill", scale: 1)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    
                                    Text("Picked")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                    
                                    Text("\(45 - i) Min")
                                }
                                
                                Spacer(minLength: 0)
                            }
                            
                            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. ")
                        }
                        .padding()
                        .background(Color.white)
                    }
                }
            }
            .padding(.top)
        }
    }
}

//MARK: - Preview
struct MainHeader_Previews: PreviewProvider {
    static var previews: some View {
        MainHeader()
    }
    
    
}


