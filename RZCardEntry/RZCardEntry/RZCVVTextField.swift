//
//  RZCVVTextField.swift
//  RZCardEntry
//
//  Created by Jason Clark on 10/7/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

final class RZCVVTextField: RZCardEntryTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholder = "CVV"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func textFieldDidChange(textField: UITextField) {
        sanitizeInput()
        super.textFieldDidChange(textField)
    }

    override var inputCharacterSet: NSCharacterSet {
        return NSCharacterSet.decimalDigitCharacterSet()
    }

    override var isValid: Bool {
        guard let text = text else {
            return false
        }

        let formatlessText = RZCardEntryTextField.removeCharactersNotContainedInSet(inputCharacterSet, text: text)
        return formatlessText.characters.count == maxLength
    }

    var maxLength: Int {
        return cardType.cvvLength
    }

}

private extension RZCVVTextField {

    func sanitizeInput() {
        guard let text = text else { return }

        let formatlessText = RZCardEntryTextField.removeCharactersNotContainedInSet(inputCharacterSet, text: text)
        guard formatlessText.characters.count <= maxLength else {
            rejectInput()
            return
        }

        self.text = formatlessText
    }

}