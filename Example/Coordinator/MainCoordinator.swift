
//
//  MainCoordinator.swift
//  demo-bambuser
//
//  Created by Nuno Patraquim on 15/10/2025.
//

import UIKit

protocol FDKDummyNavigationProtocol: AnyObject {

    func openLivestream()
}

class MainCoordinator: Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    unowned let livestreamManager: FFSLivestreamManager

    init(
        navigationController: UINavigationController,
        livestreamManager: FFSLivestreamManager
    ) {

        self.navigationController = navigationController
        self.livestreamManager = livestreamManager
    }

    func start() {

        let homeViewController = HomeViewController()
        homeViewController.navigator = self
        self.navigationController.pushViewController(homeViewController, animated: false)
    }
}

extension MainCoordinator: FDKDummyNavigationProtocol {

    func openLivestream() {

        guard self.childCoordinators.isEmpty else {

            self.childCoordinators.first?.start()
            return
        }

        let livestreamCoordinator = LivestreamCoordinator(
            navigationController: navigationController,
            manager: self.livestreamManager
        )

        self.childCoordinators.append(livestreamCoordinator)

        livestreamCoordinator.start()
    }
}
