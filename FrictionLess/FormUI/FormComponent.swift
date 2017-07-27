//
//  FormComponent.swift
//  FrictionLess
//
//  Created by Jason Clark on 7/19/17.
//
//

import Foundation

public protocol FormComponent {

    var title: String? { get set }
    var placeholder: String? { get set }
    var state: FormComponentState { get set }
    var isEnabled: Bool { get set }
    var textField: FormattableTextField { get }

}

public extension FormComponent {

    var value: String {
        get {
            return textField.unformattedText
        }
        set {
            if newValue != textField.unformattedText {
                textField.setTextAndFormat(text: newValue)
            }
        }
    }

}

public enum FormComponentState {
    case inactive
    case active
    case valid
    case invalid(errorString: String?)
}

public extension FormComponentState {

    var errorMessage: String? {
        if case .invalid(let error) = self {
            return error
        }
        else { return nil }
    }

}

public extension FormComponentState {

    static func == (lhs: FormComponentState, rhs: FormComponentState) -> Bool {
        switch (lhs, rhs) {
        case (.inactive, .inactive): return true
        case (.active, .active): return true
        case (.valid, .valid): return true
        case (.invalid(let e1), .invalid(let e2)):
            return e1 == e2
        default: return false
        }
    }
    
}
