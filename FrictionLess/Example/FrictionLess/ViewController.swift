//
//  ViewController.swift
//  FrictionLess
//
//  Created by jason.clark@raizlabs.com on 07/17/2017.
//  Copyright (c) 2017 jason.clark@raizlabs.com. All rights reserved.
//

import UIKit
@testable import FrictionLess

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func loadView() {
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray

        let ccTextField = FormattableTextField(formatter: CreditCardFormatter())
        ccTextField.translatesAutoresizingMaskIntoConstraints = false
        ccTextField.backgroundColor = .white
        view.addSubview(ccTextField)

        [ccTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
         ccTextField.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 60),
         ccTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
            ].forEach {
                $0.isActive = true
        }

        ccTextField.delegate = self
    }

}

