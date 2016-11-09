//
//  CVVFieldProcessor.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

class CVVFieldProcessor: FieldProcessor {

    var cardState: CardState = .indeterminate

    override init() {
        super.init()

        inputCharacterSet = .decimalDigits
    }

    var maxLength: Int {
        switch cardState {
        case .identified(let card): return card.cvvLength
        default: return 3
        }
    }

    override var valid: Bool {
        return unformattedText(textField).characters.count == maxLength
    }

}

private extension CVVFieldProcessor {

    func format() {
        if unformattedText(textField).characters.count > maxLength {
            //rejectInput()
        }
    }

}
