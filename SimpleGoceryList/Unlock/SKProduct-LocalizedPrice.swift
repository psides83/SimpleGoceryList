//
//  SKProduct-LocalizedPrice.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/18/21.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
