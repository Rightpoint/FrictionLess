//
//  ViewController.swift
//  RZCardEntry
//
//  Created by Jason Clark on 6/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func loadView() {
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGrayColor()

        let ccTextField = RZCardNumberTextField()
        ccTextField.backgroundColor = .whiteColor()
        ccTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ccTextField)

        let expTextField = RZExpirationDateTextField()
        expTextField.backgroundColor = .whiteColor()
        expTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(expTextField)

            [NSLayoutConstraint(item: ccTextField, attribute: .Top, relatedBy: .Equal, toItem: view.layoutMarginsGuide, attribute: .Top, multiplier: 1.0, constant: 60.0),
            NSLayoutConstraint(item: ccTextField, attribute: .Leading, relatedBy: .Equal, toItem: view.layoutMarginsGuide, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: ccTextField, attribute: .Trailing, relatedBy: .Equal, toItem: view.layoutMarginsGuide, attribute: .Trailing, multiplier: 1.0, constant: 0.0),

            NSLayoutConstraint(item: expTextField, attribute: .Top, relatedBy: .Equal, toItem: ccTextField, attribute: .Bottom, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: expTextField, attribute: .Leading, relatedBy: .Equal, toItem: view.layoutMarginsGuide, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: expTextField, attribute: .Trailing, relatedBy: .Equal, toItem: view.layoutMarginsGuide, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
            ].forEach { $0.active = true }
    }
    
    
}

