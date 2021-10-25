//
//  TextFieldMod.swift
//  SimpleGroceryList
//
//  Created by Payton Sides on 6/11/21.
//

import SwiftUI
import UIKit

@available(iOS 13.0, *)
extension CustomTextField {

    /// Sets the maximum amount of characters allowed in this text field.
    /// - Parameter limit: the maximum amount of characters allowed
    /// - Returns: An updated text field limited to limit
    public func characterLimit(_ limit: Int?) -> CustomTextField {
        var view = self
        view.characterLimit = limit
        return view
    }
    
    /// Modifies the text field’s **font** from a `UIFont` object.
    /// - Parameter font: The desired font
    /// - Returns: An updated text field using the desired font
    /// - Warning: Accepts a `UIFont` object rather than SwiftUI `Font`
    /// - SeeAlso: [`UIFont`](https://developer.apple.com/documentation/uikit/uifont)
    public func fontFromUIFont(_ font: UIFont?) -> CustomTextField {
        var view = self
        view.font = font
        return view
    }
    
    /// Modifies the **text color**  of the text field.
    /// - Parameter color: The desired text color
    /// - Returns: An updated text field using the desired text color
    @available(iOS 13, *)
    public func foregroundColor(_ color: Color?) -> CustomTextField {
        var view = self
        if let color = color {
            view.foregroundColor = UIColor.from(color: color)
        }
        return view
    }
    
    /// Modifies the **cursor color**  of the text field
    /// - Parameter accentColor: The cursor color
    /// - Returns: A phone number text field with updated cursor color
    @available(iOS 13, *)
    public func accentColor(_ accentColor: Color?) -> CustomTextField {
        var view = self
        if let accentColor = accentColor {
            view.accentColor = UIColor.from(color: accentColor)
        }
        return view
    }
    
    /// Modifies the **text alignment** of a text field.
    /// - Parameter alignment: The desired text alignment
    /// - Returns: An updated text field using the desired text alignment
    public func multilineTextAlignment(_ alignment: TextAlignment) -> CustomTextField {
        var view = self
        switch alignment {
        case .leading:
            view.textAlignment = layoutDirection ~= .leftToRight ? .left : .right
        case .trailing:
            view.textAlignment = layoutDirection ~= .leftToRight ? .right : .left
        case .center:
            view.textAlignment = .center
        }
        return view
    }
    
    /// Modifies the **content type** of a text field.
    /// - Parameter textContentType: The type of text being inputted into the text field
    /// - Returns: An updated text field using the desired text content type
    public func textContentType(_ textContentType: UITextContentType?) -> CustomTextField {
        var view = self
        view.contentType = textContentType
        return view
    }
    
    /// Modifies the text field’s **autocorrection** settings.
    /// - Parameter disable: Whether autocorrection should be disabled
    /// - Returns: An updated text field using the desired autocorrection settings
    public func disableAutocorrection(_ disable: Bool?) -> CustomTextField {
        var view = self
        if let disable = disable {
            view.autocorrection = disable ? .no : .yes
        } else {
            view.autocorrection = .default
        }
        return view
    }
    
    /// Modifies the text field’s **autocapitalization** style.
    /// - Parameter style: What types of characters should be autocapitalized
    /// - Returns: An updated text field using the desired autocapitalization style
    public func autocapitalization(_ style: UITextAutocapitalizationType) -> CustomTextField {
        var view = self
        view.autocapitalization = style
        return view
    }
    
    /// Modifies the text field’s **keyboard type**.
    /// - Parameter type: The type of keyboard that the user should get to type in the text field
    /// - Returns: An updated text field using the desired keyboard type
    public func keyboardType(_ type: UIKeyboardType) -> CustomTextField {
        var view = self
        view.keyboardType = type
        return view
    }
    
    /// Modifies the text field’s **return key** type.
    /// - Parameter type: The type of return key the user should get on the keyboard when using this text field
    /// - Returns: An updated text field using the desired return key type
    public func returnKeyType(_ type: UIReturnKeyType) -> CustomTextField {
        var view = self
        view.returnKeyType = type
        return view
    }
    
    /// Modifies the text field’s **secure entry** settings.
    /// - Parameter isSecure: Whether the text field should hide the entered characters as dots
    /// - Returns: An updated text field using the desired secure entry settings
    public func isSecure(_ isSecure: Bool) -> CustomTextField {
        var view = self
        view.isSecure = isSecure
        return view
    }
    
    /// Modifies the **clear-on-begin-editing** setting of a  text field.
    /// - Parameter shouldClear: Whether the text field should clear on editing beginning
    /// - Returns:  A text field with updated clear-on-begin-editing settings
    public func clearsOnBeginEditing(_ shouldClear: Bool) -> CustomTextField {
        var view = self
        view.clearsOnBeginEditing = shouldClear
        return view
    }
    
    /// Modifies the **clear-on-insertion** setting of a text field.
    /// - Parameter shouldClear: Whether the text field should clear on insertion
    /// - Returns: A text field with updated clear-on-insertion settings
    public func clearsOnInsertion(_ shouldClear: Bool) -> CustomTextField {
        var view = self
        view.clearsOnInsertion = shouldClear
        return view
    }
    
    /// Modifies whether and when the text field **clear button** appears on the view.
    /// - Parameter showsButton: Whether the clear button should be visible
    /// - Returns: A text field with updated clear button settings
    public func showsClearButton(_ showsButton: Bool) -> CustomTextField {
        var view = self
        view.clearButtonMode = showsButton ? .always : .never
        return view
    }
    
    /// Modifies whether the text field is **disabled**.
    /// - Parameter disabled: Whether the text field is disabled
    /// - Returns: A text field with updated disabled settings
    public func disabled(_ disabled: Bool) -> CustomTextField {
        var view = self
        view.isUserInteractionEnabled = !disabled
        return view
    }
    
    /// Modifies the text field's **password rules** . Sets secure entry to `true`.
    /// - Parameter rules: The text field's password rules.
    /// - Returns: A text field with updated password rules
    public func passwordRules(_ rules: UITextInputPasswordRules) -> CustomTextField {
        var view = self
        view.isSecure = true
        view.passwordRules = rules
        return view
    }
    
    /// Modifies whether the text field includes **smart dashes**.
    /// - Parameter smartDashes: Whether the text field includes smart dashes. Does nothing if `nil`.
    /// - Returns: A text field with the updated smart dashes settings.
    public func smartDashes(_ smartDashes: Bool? = nil) -> CustomTextField {
        var view = self
        if let smartDashes = smartDashes {
            view.smartDashesType = smartDashes ? .yes : .no
        }
        return view
    }
    
    /// Modifies whether the text field uses **smart insert-delete**.
    /// - Parameter smartInsertDelete: Whether the text field uses smart insert-delete. Does nothing if `nil`.
    /// - Returns: A text field with the updated smart insert-delete settings.
    public func smartInsertDelete(_ smartInsertDelete: Bool? = nil) -> CustomTextField {
        var view = self
        if let smartInsertDelete = smartInsertDelete {
            view.smartInsertDeleteType = smartInsertDelete ? .yes : .no
        }
        return view
    }
    
    /// Modifies whether the text field uses **smart quotes**.
    /// - Parameter smartQuotes: Whether the text field uses smart quotes. Does nothing if `nil`.
    /// - Returns: A text field with the updated smart quotes settings
    public func smartQuotes(_ smartQuotes: Bool? = nil) -> CustomTextField {
        var view = self
        if let smartQuotes = smartQuotes {
            view.smartQuotesType = smartQuotes ? .yes : .no
        }
        return view
    }
    
    /// Modifies whether the text field should check the user's **spelling**
    /// - Parameter spellChecking: Whether the text field should check the user's spelling. Does nothing if `nil`.
    /// - Returns: A text field with updated spell checking settings
    public func spellChecking(_ spellChecking: Bool? = nil) -> CustomTextField {
        var view = self
        if let spellChecking = spellChecking {
            view.spellCheckingType = spellChecking ? .yes : .no
        }
        return view
    }
    
    /// Modifies the function called when text editing **begins**.
    /// - Parameter action: The function called when text editing begins. Does nothing if `nil`.
    /// - Returns: An updated text field using the desired function called when text editing begins
    public func onEditingBegan(perform action: (() -> Void)? = nil) -> CustomTextField {
        var view = self
        if let action = action {
            view.didBeginEditing = action
        }
        return view
        
    }
    
    /// Modifies the function called when the user makes any **changes** to the text in the text field.
    /// - Parameter action: The function called when the user makes any changes to the text in the text field. Does nothing if `nil`.
    /// - Returns: An updated text field using the desired function called when the user makes any changes to the text in the text field
    public func onEdit(perform action: (() -> Void)? = nil) -> CustomTextField {
        var view = self
        if let action = action {
            view.didChange = action
        }
        return view
        
    }
    
    /// Modifies the function called when text editing **ends**. 🔚
    /// - Parameter action: The function called when text editing ends. Does nothing if `nil`.
    /// - Returns: An updated text field using the desired function called when text editing ends
    public func onEditingEnded(perform action: (() -> Void)? = nil) -> CustomTextField {
        var view = self
        if let action = action {
            view.didEndEditing = action
        }
        return view
    }
    
    
    /// Modifies the function called when the user presses the return key.
    /// - Parameter action: The function called when the user presses the return key. Does nothing if `nil`.
    /// - Returns: An updated text field using the desired funtion called when the user presses the return key
    public func onReturn(perform action: (() -> Void)? = nil) -> CustomTextField {
        var view = self
        if let action = action {
            view.shouldReturn = action
        }
        return view
    }
    
    /// Modifies the function called when the user clears the text field.
    /// - Parameter action: The function called when the user clears the text field. Does nothing if `nil`.
    /// - Returns: An updated text field using the desired function called when the user clears the text field
    public func onClear(perform action: (() -> Void)? = nil) -> CustomTextField {
        var view = self
        if let action = action {
            view.shouldClear = action
        }
        return view
    }
    
    /// Gives the text field a default style.
    /// - Parameters:
    ///   - height: How tall the text field should be, in points. Defaults to 58.
    ///   - backgroundColor: The background color of the text field. Defaults to clear.
    ///   - accentColor: The cursor and highlighting color of the text field. Defaults to light blue.
    ///   - inputFont: The font of the text field
    ///   - paddingLeading: Leading-edge padding size, in points. Defaults to 25.
    ///   - cornerRadius: Text field corner radius. Defaults to 6.
    ///   - hasShadow: Whether or not the text field has a shadow when selected. Defaults to true.
    /// - Returns: A stylized view containing a text field.
    public func style(height: CGFloat = 58,
               backgroundColor: Color? = nil,
               accentColor: Color = Color(red: 0.30, green: 0.76, blue: 0.85),
               font inputFont: UIFont? = nil,
               paddingLeading: CGFloat = 25,
               cornerRadius: CGFloat = 6,
               hasShadow: Bool = true,
               image: Image? = nil) -> some View
    {
        var darkMode: Bool { colorScheme == .dark }
        
        let cursorColor: Color = accentColor
        let height: CGFloat = height
        let leadingPadding: CGFloat = paddingLeading
        
        var backgroundGray: Double { darkMode ? 0.25 : 0.95 }
        let backgroundColor: Color = backgroundColor ?? .init(white: backgroundGray)
//        {
//            if backgroundColor != nil {
//                return backgroundColor ?? .init(white: backgroundGray)
//            } else {
//                return .init(white: backgroundGray)
//            }
//        }
        
        var shadowOpacity: Double { (designEditing && hasShadow) ? 0.5 : 0 }
        var shadowGray: Double { darkMode ? 0.8 : 0.5 }
        var shadowColor: Color { Color(white: shadowGray).opacity(shadowOpacity) }
        
        var borderColor: Color {
            designEditing && darkMode ? .init(white: 0.6) : .clear
        }
        
        var font: UIFont {
            if let inputFont = inputFont {
                return inputFont
            } else {
                let fontSize: CGFloat = 20
                let systemFont = UIFont.systemFont(ofSize: fontSize, weight: .regular)
                if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
                    return  UIFont(descriptor: descriptor, size: fontSize)
                } else {
                    return systemFont
                }
            }
        }
        
        return ZStack {
            HStack {
                if let image = image {
                    image
                }
                self
                    .accentColor(cursorColor)
                    .fontFromUIFont(font)
            }
            .padding(.horizontal, leadingPadding)
        }
        .frame(height: height)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(borderColor))
        .padding(.horizontal, leadingPadding)
        .shadow(color: shadowColor, radius: 5, x: 0, y: 4)
    }
    
    /// Since Apple has not given us a way yet to parse a `Font`   object, this function must be deprecated . Please use `.fontFromUIFont(_:)` instead .
    /// - Parameter font:
    /// - Returns:
    @available(*, deprecated, renamed: "fontFromUIFont", message: "At this time, Apple will not let us parse a `Font` object Please use `.fontFromUIFont(_:)` instead.")
    public func font(_ font: Font?) -> some View { return EmptyView() }
}
