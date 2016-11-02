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
        switch cardState {
        case .identified(let card): return card.cvvLength
        default: return 3
        }
    }

}

private extension RZCVVTextField {

    func sanitizeInput() {
        if unformattedText.characters.count > maxLength {
            rejectInput()
        }
    }

}
