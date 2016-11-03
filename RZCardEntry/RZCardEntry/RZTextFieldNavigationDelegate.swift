//
//  RZTextFieldNavigationDelegate.swift
//  RZCardEntry
//
//  Created by Jason Clark on 10/17/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

protocol RZTextFieldNavigationDelegate {

    func textFieldDidBecomeFirstResponder(_ textField: RZFormattableTextField) //addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingBegan)
    func textFieldDidChange(_ textField: RZFormattableTextField) //addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    func textField(_ textField: RZFormattableTextField, shouldForwardInput input: String)
    func textFieldBackspacePressedWithoutContent(_ textField: RZFormattableTextField)

}
