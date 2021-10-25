//
//  OnboardingView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 7/6/21.
//

import SwiftUI

struct OnboardingView: View {
    
    let features = [
        Feature(title: "Efficient", description: "Add, check off, and remove items quickly and efficiently.", image: "speedometer"),
        Feature(title: "Apple Watch", description: "Check off items from your Apple Watch while you shop.", image: "applewatch.watchface"),
        Feature(title: "Attach Image", description: "Attach an image to you list items for reference while shopping.", image: "photo.fill"),
        Feature(title: "New in V2.3", description: "UI enhancements and minor bug fixes.", image: "rays"),
        Feature(title: "Coming Soon", description: "Share your list with other iOS users.", image: "square.and.arrow.up")
    ]
        
    @AppStorage("v2point3") var v2point3: Bool = true
    
    var body: some View {
        VStack(spacing: 20) {
            ListIconView(backgroundColor: .mint, circleColor: .white, lineColor: .picked, topCircleIcon: "circle", bottomCircleIcon: "checkmark.circle.fill", scale: 2)
            
            Text("Welcome to \(Text("Picked").foregroundColor(.mint))")
                .multilineTextAlignment(.center)
                .font(.title.bold())
                .frame(width: 250)

            ForEach(features) { feature in
                HStack {
                    Image(systemName: feature.image)
                        .frame(width: 44)
                        .font(.title)
                        .foregroundColor(.mint)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading) {
                        Text(feature.title)
                            .font(.headline)
                            .foregroundColor(.orangeLight)

                        Text(feature.description)
                            .foregroundColor(.picked)
                    }
                    .accessibilityElement(children: .combine)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button {
                close()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.mint)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    func close() {
        v2point3 = false
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

struct Feature: Decodable, Identifiable {
    var id = UUID()
    let title: String
    let description: String
    let image: String
}
