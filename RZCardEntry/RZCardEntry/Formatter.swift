//
//  Formatter.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

struct EditingEvent {
    var oldValue: String
    var editRange: NSRange
    var editString: String
    var newValue: String
    var newCursorPosition: Int
}

enum ValidationResult {
    case valid(String, Int)
    case invalid
}

protocol Formatter {

    var inputCharacterSet: CharacterSet { get }
    var formattingCharacterSet: CharacterSet { get }
    var deletingShouldRemoveTrailingCharacters: Bool { get }

    func valid(_ string: String) -> Bool
    func validateAndFormat(editingEvent: EditingEvent) -> ValidationResult

}

//protocol defaults, for now
extension Formatter {

    var inputCharacterSet: CharacterSet {
        return CharacterSet().inverted
    }

    var formattingCharacterSet: CharacterSet {
        return CharacterSet()
    }

    var deletingShouldRemoveTrailingCharacters: Bool {
        return false
    }

}

extension Formatter {

    func removeFormatting(_ text: String) -> String {
        return text.filteringWith(characterSet: inputCharacterSet)
    }

    func removeFormatting(_ text: String, cursorPosition: inout Int) -> String {
        return text.filteringWith(characterSet: inputCharacterSet, cursorPosition: &cursorPosition)
    }

}

extension String {

    func filteringWith(characterSet: CharacterSet) -> String {
        return components(separatedBy: characterSet.inverted).joined()
    }

    func filteringWith(characterSet: CharacterSet, cursorPosition: inout Int) -> String {
        let originalCursorPosition = cursorPosition
        var validChars = String()
        for (index, character) in characters.enumerated() {
            if String(character).rangeOfCharacter(from: characterSet) != nil {
                validChars.append(character)
            }
            else if index < originalCursorPosition {
                cursorPosition -= 1
            }
        }
        return validChars
    }
    
}
