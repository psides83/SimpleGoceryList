//
//  CheckToggleStyle.swift
//  CustomerManager
//
//  Created by Payton Sides on 3/23/21.
//

import Foundation
import SwiftUI

struct CheckToggleStyle: ToggleStyle {
    @ObservedObject private var haptics = Haptics()
    private let impactMed = UIImpactFeedbackGenerator(style: .rigid)

        
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Button {
                
                configuration.isOn.toggle()
                impactMed.impactOccurred()
            } label: {
                
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .foregroundColor(.mint)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}
