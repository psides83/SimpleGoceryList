//
//  IntroPageView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/14/21.
//

import SwiftUI

struct IntroPageView: View {
    
    //MARK: - Properties
    @AppStorage("listTitle") var listTitle = ""
    @AppStorage("isShowingIntroPage") var isShowingIntroPage = true

    //MARK: - Body
    var body: some View {
        ZStack {
            VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
            VStack {
                Text("Give your list a title")
                    .font(.title.weight(.bold))
                    .foregroundColor(.secondary)
                TextField("add a list title", text: $listTitle)
                    .autocapitalization(.words)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button {
                    withAnimation {
                        isShowingIntroPage = false
                    }
                } label: {
                    Text("Continue")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.mint)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
            }
            .padding()
            .background(VisualEffectBlur(blurStyle: .systemMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: - Preview
struct IntroPageView_Previews: PreviewProvider {
    
    static var previews: some View {
        IntroPageView()
    }
}
