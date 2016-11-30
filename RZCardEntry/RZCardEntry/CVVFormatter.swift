//
//  CVVFormatter.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

struct CVVFormatter: Formatter {

    var inputCharacterSet: CharacterSet {
        return .decimalDigits
    }

    var maxLength = 3

    func valid(_ string: String) -> Bool {
        return string.characters.count == maxLength
    }

    func validateAndFormat(editingEvent: EditingEvent) -> ValidationResult {
        if editingEvent.newValue.characters.count <= maxLength {
            return .valid(editingEvent.newValue, editingEvent.newCursorPosition)
        }
        else {
            return .invalid
        }
    }

}
