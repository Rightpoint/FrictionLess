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

}
