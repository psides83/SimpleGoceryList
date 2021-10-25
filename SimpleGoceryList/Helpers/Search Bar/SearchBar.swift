//
//  SearchBar.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/14/21.
//

import Foundation
import SwiftUI

extension SearchBar.Coordinator: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

        // Publish search bar text changes.
        if let searchBarText = searchController.searchBar.text {
            self.text = searchBarText
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    class Coordinator: NSObject, UISearchBarDelegate, ObservableObject {
        
        @Binding var text: String
        let searchController: UISearchController = UISearchController(searchResultsController: nil)
        
        init(text: Binding<String>) {
            _text = text
            super.init()
            self.searchController.obscuresBackgroundDuringPresentation = false
            self.searchController.searchResultsUpdater = self
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "Search"
        
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
    
    
}

struct SearchBarModifier: ViewModifier {
    
    let searchBarCoordinator: SearchBar.Coordinator
    let searchBar: SearchBar
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ViewControllerResolver { viewController in
                    viewController.navigationItem.searchController = searchBarCoordinator.searchController
                }
                    .frame(width: 0, height: 0)
            )
    }
}

extension View {
    
    func add(_ searchBar: SearchBar, searchBarCoordinator: SearchBar.Coordinator) -> some View {
        return self.modifier(SearchBarModifier(searchBarCoordinator: searchBarCoordinator, searchBar: searchBar))
    }
}
