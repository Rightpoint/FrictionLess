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
        let expTextField = RZExpirationDateTextField()
        let cvvTextField = RZCVVTextField()
        let imageView = RZCardImageView()

        let coordinator = RZCardEntryCoordinator()
        coordinator.creditCardTextField = ccTextField
        coordinator.expirationDateTextField = expTextField
        coordinator.cvvTextField = cvvTextField
        coordinator.imageView = imageView

        [ccTextField, expTextField, cvvTextField].forEach {
            $0.backgroundColor = .whiteColor()
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        [ccTextField.topAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.topAnchor, constant: 60.0),
            imageView.topAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.topAnchor, constant: 60.0),
            imageView.widthAnchor.constraintEqualToConstant(40),
            imageView.leadingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leadingAnchor),

            ccTextField.leadingAnchor.constraintEqualToAnchor(imageView.trailingAnchor, constant: 20.0),
            ccTextField.trailingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.trailingAnchor),

            expTextField.topAnchor.constraintEqualToAnchor(ccTextField.bottomAnchor, constant: 20.0),
            expTextField.leadingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leadingAnchor),

            cvvTextField.leadingAnchor.constraintEqualToAnchor(expTextField.trailingAnchor, constant: 20.0),
            cvvTextField.trailingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.trailingAnchor),
            cvvTextField.topAnchor.constraintEqualToAnchor(ccTextField.bottomAnchor, constant: 20.0),
            cvvTextField.widthAnchor.constraintEqualToAnchor(expTextField.widthAnchor)
            ].forEach { $0.active = true }
    }
    
    
}

