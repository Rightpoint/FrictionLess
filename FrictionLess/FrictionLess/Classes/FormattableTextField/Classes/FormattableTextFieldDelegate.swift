//
//  FormattableTextFieldDelegate.swift
//  Raizlabs
//
//  Created by Jason Clark on 3/27/17.
//
//

import UIKit

protocol FormattableTextFieldDelegate: UITextFieldDelegate {
    func textFieldShouldNavigateBackwards(_ textField: FormattableTextField)
    func textField(_ textField: FormattableTextField, didOverflowInput string: String)
    func textField(_ textField: FormattableTextField, invalidInput error: Error)
    func editingChanged(textField: FormattableTextField)
}

extension FormattableTextFieldDelegate {
    func textFieldShouldNavigateBackwards(_ textField: FormattableTextField) {}
    func textField(_ textField: FormattableTextField, didOverflowInput string: String) {}
    func textField(_ textField: FormattableTextField, invalidInput error: Error) {}
    func editingChanged(textField: FormattableTextField) {}
}
