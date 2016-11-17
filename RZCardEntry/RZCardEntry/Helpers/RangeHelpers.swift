//
//  RangeHelpers.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

extension String {

    func substring(fromNSRange range: NSRange) -> String {
        return substring(with: self.range(fromNSRange: range))
    }

    func range(fromNSRange range: NSRange) -> Range<String.Index> {
        return characters.index(startIndex, offsetBy: range.location)..<characters.index(startIndex, offsetBy: range.location + range.length)
    }

}

extension UITextField {

    var cursorOffset: Int {
        guard let startPosition = selectedTextRange?.start else {
            return 0
        }
        return offset(from: beginningOfDocument, to: startPosition)
    }

    func offsetTextRange(_ selection: UITextRange?, by offset: Int) -> UITextRange? {
        guard let selection = selection, let start = self.position(from: selection.start, offset: offset),
            let end = self.position(from: selection.end, offset: offset) else {
                return nil
        }
        return textRange(from: start, to: end)
    }

    func textRange(cursorOffset: Int) -> UITextRange? {
        guard let targetPosition = position(from: beginningOfDocument, offset: cursorOffset) else {
            return nil
        }
        return textRange(from: targetPosition, to: targetPosition)
    }
    
}
