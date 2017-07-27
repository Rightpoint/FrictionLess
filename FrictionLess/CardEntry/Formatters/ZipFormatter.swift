//
//  ZipFormatter.swift
//  FrictionLess
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

enum ZipFormatterError: Error {
    case minLength
    case maxLength
}

public struct ZipFormatter: TextFieldFormatter {

    var requiredLength = 5

    public var inputCharacterSet: CharacterSet {
        return .decimalDigits
    }

    public func validate(_ string: String) -> ValidationResult {
        let length = string.characters.count
        if length < requiredLength {
            return .invalid(validationError: ZipFormatterError.minLength)
        }
        else if length > requiredLength {
            return .invalid(validationError: ZipFormatterError.maxLength)
        }
        else {
            return .valid
        }
    }

    public func format(editingEvent: EditingEvent) -> FormattingResult {
        if editingEvent.newValue.characters.count <= requiredLength {
            return .valid(nil)
        }
        else {
            return .invalid(formattingError: ZipFormatterError.maxLength)
        }
    }

    public func isComplete(_ text: String) -> Bool {
        return validate(text) == .valid
    }

    public init() {}

}
