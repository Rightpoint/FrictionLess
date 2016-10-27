//
//  RZCardEntryDelegateProtocol.swift
//  RZCardEntry
//
//  Created by Jason Clark on 10/17/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

protocol RZCardEntryDelegateProtocol {

    func cardEntryTextFieldDidChange(_ textField: RZCardEntryTextField)
    func cardEntryTextField(_ textField: RZCardEntryTextField, shouldForwardInput input: String)
    func cardEntryTextFieldBackspacePressedWithoutContent(_ textField: RZCardEntryTextField)

}
