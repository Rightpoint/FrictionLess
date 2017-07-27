//
//  PhoneFormatter.swift
//  SimpliSafe
//
//  Created by Jason Clark on 4/20/17.
//
//

import Foundation
import PhoneNumberKit

public enum PhoneFormatterError: Error {
    case invalid
}

public struct PhoneFormatter: TextFieldFormatter {

    fileprivate let phoneKit = PhoneNumberKit()
    fileprivate let partialFormatter: PartialFormatter

    public init() {
        partialFormatter = PartialFormatter(phoneNumberKit: phoneKit)
    }

    public var inputCharacterSet: CharacterSet {
        let decimalSet = CharacterSet.decimalDigits
        let symobls = "+" //TODO if backend supported? "*#,;"
        let symbolSet = CharacterSet(charactersIn: symobls)
        return decimalSet.union(symbolSet)
    }

    public var formattingCharacterSet: CharacterSet {
        return CharacterSet(charactersIn: "()- ")
    }

    public func format(editingEvent: EditingEvent) -> FormattingResult {
        let formatted = partialFormatter.formatPartial(editingEvent.newValue)
        return .valid(.text(formatted))
    }

    public func validate(_ text: String) -> ValidationResult {
        if (try? phoneKit.parse(text)) != nil {
            return .valid
        }
        return .invalid(validationError: PhoneFormatterError.invalid)
    }

}
