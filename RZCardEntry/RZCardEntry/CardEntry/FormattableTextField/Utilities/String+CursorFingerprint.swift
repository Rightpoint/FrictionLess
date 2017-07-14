//
//  String+CursorFingerprint.swift
//  Raizlabs
//
//  Created by Jason Clark on 4/21/17.
//
//

import Foundation

// Adopted from PhoneNumberKit's PhonenumberTextfield by Roy Marmelstein
// For most auto-formatting edits, the cursor location can be identified and recovered by noting how many times the character to the right of the cursor appears until the end of the string.

/// The "fingerprint" of the cursor position, as represented by the character following the cursor, and the number of times that character appears until the end of the sting
struct CursorPositionFingerprint {
    let characterAfterCursor: String
    let repetitionCountFromEnd: Int
}

extension String {

    func fingerprint(ofCursorPosition cursorPosition: Int, characterSet: CharacterSet = CharacterSet()) -> CursorPositionFingerprint? {
        var characterRepetitionsFromEnd = 0
        for i in cursorPosition ..< characters.count {
            let range = NSRange(location: i, length: 1)
            let firstCharacterAfterCursorInSet = substring(fromNSRange: range)
            if !(rangeOfCharacter(from: characterSet)?.isEmpty ?? true) {
                for j in range.location ..< characters.count {
                    let candidateRepeat = substring(fromNSRange: NSRange(location:j, length:1))
                    if candidateRepeat == firstCharacterAfterCursorInSet {
                        characterRepetitionsFromEnd += 1
                    }
                }
                return CursorPositionFingerprint(characterAfterCursor: firstCharacterAfterCursorInSet, repetitionCountFromEnd: characterRepetitionsFromEnd)
            }
        }
        return nil
    }

    func position(ofCursorFingerprint cursorFingerprint: CursorPositionFingerprint) -> Int? {
        var countFromEnd = 0

        for i in stride(from: characters.count - 1, through: 0, by: -1) {
            let candidateRange = NSRange(location: i, length:1)
            let candidateCharacter = substring(fromNSRange: candidateRange)
            if candidateCharacter == cursorFingerprint.characterAfterCursor {
                countFromEnd += 1
                if countFromEnd == cursorFingerprint.repetitionCountFromEnd {
                    return candidateRange.location
                }
            }
        }
        return nil
    }

}
