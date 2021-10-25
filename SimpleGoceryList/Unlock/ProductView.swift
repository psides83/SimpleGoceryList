//
//  ProductView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/18/21.
//

import StoreKit
import SwiftUI

struct ProductView: View {
    
    //MARK: - Properties
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var unlockManager: UnlockManager
    
    let product: SKProduct
    
    
    let features = [
        Feature(title: "History", description: "Store list items in history and quickly re-using them in the future.", image: "clock"),
        Feature(title: "Quick Add Buttons", description: "Items from history are suggested when typing in the \"add item\" text field.", image: "speedometer"),
        Feature(title: "Unlimited Items", description: "List unlimited items in the current and history list.", image: "list.bullet"),
//        Feature(title: "New in V2.3", description: "UI enhancements and minor bug fixes.", image: "rays"),
        Feature(title: "Coming Soon", description: "Share your list with other iOS users.", image: "square.and.arrow.up")
    ]
    
    //MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                VStack {
                    ListIconView(backgroundColor: .mint, circleColor: .white, lineColor: .picked, topCircleIcon: "circle", bottomCircleIcon: "checkmark.circle.fill", scale: 2)
                    
                    Text("Get \(Text("Picked").foregroundColor(.mint)) Premium")
                        .multilineTextAlignment(.center)
                        .font(.title.bold())
                        .frame(width: 300)
                }
                .padding()
                
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
                
                Spacer()
                Button("Upgrade: \(product.localizedPrice)", action: unlock)
                    .buttonStyle(PurchaseButton())
                
                Button("Restore Purchase", action: unlockManager.restore)
                    .buttonStyle(PurchaseButton())
            }
        }
    }
    
    //MARK: - Functions
    func unlock() {
        unlockManager.buy(product: product)
    }
}

