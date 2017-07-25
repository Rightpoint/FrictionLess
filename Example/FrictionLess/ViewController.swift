//
//  ViewController.swift
//  FrictionLess
//
//  Created by jason.clark@raizlabs.com on 07/17/2017.
//  Copyright (c) 2017 jason.clark@raizlabs.com. All rights reserved.
//

import FrictionLess
import Anchorage

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
        addChildViewController(form)
        form.didMove(toParentViewController: self)

        form.view.topAnchor == view.layoutMarginsGuide.topAnchor + 60
        form.horizontalAnchors == view.layoutMarginsGuide.horizontalAnchors
    }

}
