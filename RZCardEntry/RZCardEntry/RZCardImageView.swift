//
//  RZCardImageView.swift
//  RZCardEntry
//
//  Created by Jason Clark on 10/19/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

final class RZCardImageView: UIImageView {

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        image = UIImage(named: "credit_cards_generic")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}