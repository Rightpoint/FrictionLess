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

}

private extension ZipCodeFieldProcessor {

    func format() {
        if unformattedText(textField).characters.count == maxLength {
            //rejectInput()
        }
    }

}
