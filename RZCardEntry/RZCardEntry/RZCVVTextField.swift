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
    
}

private extension RZCVVTextField {

    func sanitizeInput() {
        guard let text = text else { return }

        var cursorPosition = 0
        let formatlessText = RZCardEntryTextField.removeNonDigits(text, cursorPosition: &cursorPosition)
        guard formatlessText.characters.count <= 4 else {
            rejectInput()
            return
        }

        self.text = formatlessText
    }

}