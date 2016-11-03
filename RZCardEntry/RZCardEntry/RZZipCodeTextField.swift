//
//  RZZipCodeTextField.swift
//  RZCardEntry
//
//  Created by Jason Clark on 10/17/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

final class RZZipCodeTextField: RZFormattableTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholder = "ZIP"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func textFieldDidChange(_ textField: UITextField) {
        sanitizeInput()
        super.textFieldDidChange(textField)
    }

    override var inputCharacterSet: CharacterSet {
        return CharacterSet.decimalDigits
    }

    override var valid: Bool {
        return unformattedText.characters.count == maxLength
    }

    var maxLength: Int {
        return 5
    }

}

private extension RZZipCodeTextField {

    func sanitizeInput() {
        if unformattedText.characters.count > maxLength {
            rejectInput()
        }
    }
    
}
