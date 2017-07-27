//
//  ExampleMenuViewController.swift
//  FrictionLess
//
//  Created by Jason Clark on 7/27/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Anchorage

final class ExampleMenuViewController: UIViewController {

    typealias MenuItem = (title: String, ViewControllerType: UIViewController.Type)

    let dataSource: [MenuItem] = [
        ("FormattableTextField", FormattableTextFieldExampleViewController.self),
        ("Card Entry", CardEntryExampleViewController.self),
    ]

    let reuseID = "\(UITableViewCell.self)"
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FrictionLess"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    override func loadView() {
        view = UIView()
        view.addSubview(tableView)
        tableView.edgeAnchors == view.edgeAnchors
    }

}

extension ExampleMenuViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = dataSource[indexPath.row].title
        return cell
    }

}

extension ExampleMenuViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = dataSource[indexPath.row].ViewControllerType.init()
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
