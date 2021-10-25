//
//  Extensions.swift
//  LeadManager
//
//  Created by Payton Sides on 4/8/21.
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

//MARK: - Int
extension Int16 {
    var int: Int {
        return Int(self)
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
    static let appOrange = Color("appOrange")
    static let orangeLight = Color("orangeLight")
    static let picked = Color.gray.opacity(0.8)
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
}

extension UIColor {
    static let secondary = UIColor(Color.secondary)
    static let mint = UIColor(Color.mint)
    static let picked = UIColor(Color.picked)
    static let orangeLight = UIColor(Color.orangeLight)
}

//MARK: - View
#if os(iOS)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
