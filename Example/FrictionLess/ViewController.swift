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
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)

        let form = CardEntryViewController()
        view.addSubview(form.view)
        addChildViewController(form)
        form.didMove(toParentViewController: self)

        form.view.topAnchor == view.layoutMarginsGuide.topAnchor + 60
        form.view.horizontalAnchors == view.layoutMarginsGuide.horizontalAnchors
        style(cardEntryView: form.cardEntryView)
    }

    func style(cardEntryView view: CardEntryView) {
        let textFields = FormattableTextField.appearance()
        textFields.backgroundColor = .white
        textFields.cornerRadius = 5

        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        view.layer.cornerRadius = 10
    }

}
