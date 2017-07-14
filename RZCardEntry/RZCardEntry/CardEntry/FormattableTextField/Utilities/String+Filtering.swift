//
//  String+Filtering.swift
//  Raizlabs
//
//  Created by Jason Clark on 3/29/17.
//
//

import Foundation

extension String {

    /**
     Trim out characters not contained in `characterSet`

     - Parameter characterSet: The whitelist `CharacterSet` to filter the string to.
     - Returns: A string containing only characters in `characterSet`
     */
    func filteringWith(characterSet: CharacterSet) -> String {
        return components(separatedBy: characterSet.inverted).joined()
    }

    /**
     Trim out characters not contained in `characterSet`, adjusting an index appropriately.

     - Parameter characterSet: The whitelist `CharacterSet` to filter the string to.
     - Parameter index: an index to be updated to reflect the edits to the input text.
     */

    func filteringWith(characterSet: CharacterSet, index: inout Int) -> String {
        let originalIndex = index
        var validChars = String()
        for (idx, character) in characters.enumerated() {
            if String(character).rangeOfCharacter(from: characterSet) != nil {
                validChars.append(character)
            }
            else if idx < originalIndex {
                index -= 1
            }
        }
        return validChars
    }

}
