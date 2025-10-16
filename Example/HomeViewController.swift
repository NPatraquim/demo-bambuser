
//
//  HomeViewController.swift
//  demo-bambuser
//
//  Created by Nuno Patraquim on 15/10/2025.
//

import UIKit

protocol HomeViewControllerDelegate: AnyObject {
    func openLivestream()
}

class HomeViewController: UIViewController {

    weak var navigator: FDKDummyNavigationProtocol?

    private let openStreamButton: UIButton = {

        let button = UIButton(type: .system)
        button.setTitle("Open Stream", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {

        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.view.addSubview(openStreamButton)

        NSLayoutConstraint.activate([
            openStreamButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openStreamButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        self.openStreamButton.addTarget(self, action: #selector(openStreamButtonTapped), for: .touchUpInside)
    }

    @objc
    private func openStreamButtonTapped() {

        self.navigator?.openLivestream()
    }
}
