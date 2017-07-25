//
//  ViewController.swift
//  FrictionLess
//
//  Created by jason.clark@raizlabs.com on 07/17/2017.
//  Copyright (c) 2017 jason.clark@raizlabs.com. All rights reserved.
//

import FrictionLess

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func loadView() {
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray

        let form = CardEntryViewController()
        view.addSubview(form.view)
        form.didMove(toParentViewController: self)
        form.view.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false

        [form.view.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
         form.view.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 60),
         form.view.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            ].forEach {
                $0.isActive = true
        }
    }

}
