//
//  WatchExtensions.swift
//  WatchSimpleGroceryList Extension
//
//  Created by Payton Sides on 6/14/21.
//

import SwiftUI
import Foundation


//MARK: - Double
extension Double {
    var currency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        return numberFormatter.string(for: self) ?? ""
    }
    
    var string: String {
        return String(self)
    }
    
    var cgfloat: CGFloat {
        return CGFloat(truncating: NSNumber(value: self))
    }
}

//MARK: - CGFloat
extension CGFloat {
    var currency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        return numberFormatter.string(for: self) ?? ""
    }
    
    var double: Double {
        return Double(self)
    }
    
    var int: Int {
        return Int(self)
    }
}

//MARK: - String
extension String {
    var double: Double {
        return Double(self) ?? 0.0
    }
}

//MARK: - Int
extension Int {
    var currency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        return numberFormatter.string(for: self) ?? ""
    }
    
    var string: String {
        return String(self)
    }
    
    var cgfloat: CGFloat {
        return CGFloat(truncating: NSNumber(value: self))
    }
}

//MARK: - Date
extension Date {
    var yearInt: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return Int(formatter.string(from: self)) ?? 2021
    }
    
    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    var monthAbriviated: String {
        let format = DateFormatter()
        format.dateFormat = "MMM"
        return format.string(from: self)
    }
    
    var medium: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var dateOnly: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

//MARK: - Color
extension Color {
    static let mint = Color("mint")
    static let picked = Color.gray.opacity(0.8)
    static let orangeLight = Color("orangeLight")
}

//MARK: - View
#if os(iOS)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
