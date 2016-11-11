//
//  ZipCodeFieldProcessor.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

class ZipCodeFieldProcessor: FieldProcessor {

    let maxLength = 5

    override var textField: UITextField? {
        didSet {
            textField?.placeholder = "ZIP"
        }
    }

    override init() {
        super.init()
        inputCharacterSet = .decimalDigits
    }

    override var valid: Bool {
        return unformattedText(textField).characters.count == maxLength
    }

    override func validateAndFormat(edit: EditingEvent) -> ValidationResult {
        if removeFormatting(edit.newValue).characters.count <= maxLength {
            return .valid(edit.newValue, edit.newCursorPosition)
        }
        else {
            return .invalid
        }
    }

}
