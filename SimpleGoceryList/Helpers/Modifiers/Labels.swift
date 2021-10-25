//
//  Labels.swift
//  CustomerManager
//
//  Created by Payton Sides on 3/24/21.
//

import SwiftUI

struct Labels: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct Labels_Previews: PreviewProvider {
    static var previews: some View {
        Labels()
    }
}

struct WideLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .foregroundColor(.secondary)
            Spacer()
            configuration.title
                .foregroundColor(.blue)
        }
    }
}

struct ReverseLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

struct HeaderLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

struct VerticalLabelStyle: LabelStyle {
    var alignment: HorizontalAlignment
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: alignment) {
            configuration.icon
                .foregroundColor(.blue)
            configuration.title
                .foregroundColor(.blue)
                .font(.subheadline)
        }
    }
}
