//
//  RZTextFieldNavigationDelegate.swift
//  RZCardEntry
//
//  Created by Jason Clark on 10/17/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

protocol RZTextFieldNavigationDelegate: UITextFieldDelegate {

    func textField(_ textField: RZFormattableTextField, shouldForwardInput input: String)
    func textFieldBackspacePressedWithoutContent(_ textField: RZFormattableTextField)

}
