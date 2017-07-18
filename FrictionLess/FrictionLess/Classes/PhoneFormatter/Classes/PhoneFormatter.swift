//
//  PhoneFormatter.swift
//  SimpliSafe
//
//  Created by Jason Clark on 4/20/17.
//
//

import Foundation
import PhoneNumberKit

enum PhoneFormatterError: Error {
    case invalid
}

struct PhoneFormatter: TextFieldFormatter {

    let phoneKit = PhoneNumberKit()
    let partialFormatter: PartialFormatter

    init() {
        partialFormatter = PartialFormatter(phoneNumberKit: phoneKit)
    }

    var inputCharacterSet: CharacterSet {
        let decimalSet = CharacterSet.decimalDigits
        let symobls = "+" //TODO if backend supported? "*#,;"
        let symbolSet = CharacterSet(charactersIn: symobls)
        return decimalSet.union(symbolSet)
    }

    var formattingCharacterSet: CharacterSet {
        return CharacterSet(charactersIn: "()- ")
    }

    func format(editingEvent: EditingEvent) -> FormattingResult {
        let formatted = partialFormatter.formatPartial(editingEvent.newValue)
        return .valid(.text(formatted))
    }

    func validate(_ text: String) -> ValidationResult {
        if (try? phoneKit.parse(text)) != nil {
            return .valid
        }
        return .invalid(validationError: PhoneFormatterError.invalid)
    }

}
