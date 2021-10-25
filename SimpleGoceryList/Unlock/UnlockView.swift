//
//  UnlockView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/18/21.
//

import StoreKit
import SwiftUI

struct UnlockView: View {
    
    //MARK: - Properties
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var unlockManager: UnlockManager
    
    //MARK: - Body
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.picked)
                }
            }
            
            switch unlockManager.requestState {
            case .loaded(let product):
                ProductView(product: product)
            case .failed(_):
                Text("Sorry, there was an error loading the store. Please try again later.")
            case .loading:
                ProgressView("Loading…")
            case .purchased:
                Text("Thank you!")
            case .deferred:
                Text("Thank you! Your request is pending approval, but you can carry on using the app in the meantime.")
            }
        }
        .padding()
        .onReceive(unlockManager.$requestState) { value in
            if case .purchased = value {
                dismiss()
            }
        }
    }
    
    //MARK: - Functions
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}
