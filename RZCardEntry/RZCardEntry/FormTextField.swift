//
//  FormTextField.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

class FormTextField: UITextField {

    override func deleteBackward() {
        if text?.characters.count == 0 {
            //if delete is pressed in an empty textfield, interpret this as a navigation to previous field
            //navigationDelegate?.textFieldBackspacePressedWithoutContent(self)
        }
        super.deleteBackward()
    }

}
