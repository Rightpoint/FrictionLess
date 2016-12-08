//
//  ViewController.swift
//  RZCardEntry
//
//  Created by Jason Clark on 6/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    let form = CreditCardForm()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func loadView() {
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray

        let ccTextField = UITextField()
        ccTextField.placeholder = "0000 0000 0000 0000"
        ccTextField.keyboardType = .numberPad

        let expTextField = UITextField()
        expTextField.placeholder = "MM/YY"
        expTextField.keyboardType = .numberPad

        let cvvTextField = UITextField()
        cvvTextField.placeholder = "CVV"
        cvvTextField.keyboardType = .numberPad

        let imageView = UIImageView()

        form.creditCardTextField = ccTextField
        form.expirationTextField = expTextField
        form.cvvTextField = cvvTextField
        form.imageView = imageView

        [ccTextField, expTextField, cvvTextField].forEach {
            $0.backgroundColor = .white
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        [ccTextField.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 60.0),
            imageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 60.0),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),

            ccTextField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20.0),
            ccTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            expTextField.topAnchor.constraint(equalTo: ccTextField.bottomAnchor, constant: 20.0),
            expTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),

            cvvTextField.leadingAnchor.constraint(equalTo: expTextField.trailingAnchor, constant: 20.0),
            cvvTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            cvvTextField.topAnchor.constraint(equalTo: ccTextField.bottomAnchor, constant: 20.0),
            cvvTextField.widthAnchor.constraint(equalTo: expTextField.widthAnchor)
            ].forEach { $0.isActive = true }
    }

}

