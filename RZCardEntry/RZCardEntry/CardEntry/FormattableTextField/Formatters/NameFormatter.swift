//
//  NameFormatter.swift
//  Raizlabs
//
//  Created by Jason Clark on 4/19/17.
//
//

import Foundation

enum NameFormatterError: Error {
    case empty
}

struct NameFormatter: TextFieldFormatter {

    var minimumLength = 1

    func validate(_ text: String) -> ValidationResult {
        let length = text.characters.count
        if length < minimumLength {
            return .invalid(validationError: NameFormatterError.empty)
        }
        else {
            return .valid
        }
    }

}
