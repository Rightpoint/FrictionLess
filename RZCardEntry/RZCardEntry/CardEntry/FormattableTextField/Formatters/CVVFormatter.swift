//
//  CVVFormatter.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

enum CVVFormatterError: Error {
    case minLength
    case maxLength
}

struct CVVFormatter: TextFieldFormatter {

    var requiredLength = 3

    var inputCharacterSet: CharacterSet {
        return .decimalDigits
    }

    func validate(_ string: String) -> ValidationResult {
        let length = string.characters.count
        if length < requiredLength {
            return .invalid(validationError: CVVFormatterError.minLength)
        }
        else if length > requiredLength {
            return .invalid(validationError: CVVFormatterError.maxLength)
        }
        else {
            return .valid
        }
    }

    func format(editingEvent: EditingEvent) -> FormattingResult {
        if editingEvent.newValue.characters.count <= requiredLength {
            return .valid(nil)
        }
        else {
            return .invalid(formattingError: CVVFormatterError.maxLength)
        }
    }

    func isComplete(_ text: String) -> Bool {
        if case .valid = validate(text) {
            return true
        }
        return false
    }

}
