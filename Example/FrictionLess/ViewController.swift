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

    var doneButton: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Card Entry"

        doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                        target: self,
                        action: #selector(doneButtonPressed))
        navigationItem.rightBarButtonItem = doneButton
        doneButton?.isEnabled = false
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)

        let form = CardEntryViewController()
        form.delegate = self
        view.addSubview(form.view)
        addChildViewController(form)
        form.didMove(toParentViewController: self)

        form.view.topAnchor == view.layoutMarginsGuide.topAnchor + 80
        form.view.horizontalAnchors == view.layoutMarginsGuide.horizontalAnchors
        style(cardEntryView: form.cardEntryView)
    }

}

extension ViewController: CardEntryViewControllderDelegate {

    func cardEntryViewController(_ vc: CardEntryViewController, creditCardValid: Bool) {
        doneButton?.isEnabled = creditCardValid
    }

}

fileprivate extension ViewController {

    func style(cardEntryView view: CardEntryView) {
        let fieldAppearance = FormattableTextField.appearance()
        fieldAppearance.backgroundColor = .white
        fieldAppearance.cornerRadius = 5

        let componentAppearance = FrictionLessFormComponent.appearance()
        componentAppearance.titleToTextFieldPadding = 3

        let validationAppearance = FrictionLessFormValidationLabel.appearance()
        validationAppearance.textColor = .red

        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        view.layer.cornerRadius = 10

        view.creditCard.titleLabel.layoutMargins.bottom = 30
    }

    @objc func doneButtonPressed() {
        let alert = UIAlertController(title: "Card Submitted",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hooray!", style: UIAlertActionStyle.default))
        present(alert, animated: true, completion: nil)
    }

}
