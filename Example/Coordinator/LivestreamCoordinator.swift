
//
//  LivestreamCoordinator.swift
//  demo-bambuser
//
//  Created by Nuno Patraquim on 15/10/2025.
//

import UIKit

protocol FDKDismissalNavigationProtocol: AnyObject {

    func dismissModalNavigation(completion: (() -> Void)?)
}

protocol FDKLivestreamNavigationProtocol: AnyObject {

    func navigateToLivestreamViewController(videoID: String)
    func navigateToLivestreamViewControllerFromPip(controller: FFSLivestreamControllable?)
}

final class LivestreamCoordinator: Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    unowned let livestreamManager: FFSLivestreamManager

    init(
        navigationController: UINavigationController,
        manager: FFSLivestreamManager
    ) {

        self.navigationController = navigationController
        self.livestreamManager = manager

        self.livestreamManager.navigator = self
    }

    func start() {

        //mimic deeplink performNavigation call
        self.livestreamManager.performLivestreamNavigation(
            videoID: "du6xAZNVHXlPs6XoTXbT"
        ) { value in }
    }
}

extension LivestreamCoordinator: FDKDismissalNavigationProtocol {

    func dismissModalNavigation(completion: (() -> Void)?) {

        self.navigationController.viewControllers.last?.dismiss(animated: true, completion: completion)
    }
}

extension LivestreamCoordinator: FDKLivestreamNavigationProtocol {

    func navigateToLivestreamViewController(videoID: String) {

        let vc = self.livestreamViewController

        self.navigationController.present(
            vc,
            animated: true
        )
    }

    func navigateToLivestreamViewControllerFromPip(
        controller: FFSLivestreamControllable?
    ) {

        guard let controller = controller else { return }

        self.navigationController.present(controller, animated: true)
    }
}

private extension LivestreamCoordinator {

    var livestreamViewController: FFSLivestreamViewController {

        let settings = FFSLivestreamSettings(
            videoID: "du6xAZNVHXlPs6XoTXbT",
            isAutoPlayEnabled: true,
            isCartViewEnabled: false,
            isCartButtonEnabled: false,
            isChatOverlayEnabled: true,
            isProductListEnabled: true,
            isProductDetailEnabled: false,
            isShareButtonEnabled: false
        )

        let viewModel = FFSLivestreamViewModel(
            settings: settings,
            jurisdiction: Jurisdiction()
        )

        let vc = FFSLivestreamViewController(
            viewModel: viewModel,
            livestreamManager: self.livestreamManager
        )

        vc.navigator = self

        return vc
    }
}
