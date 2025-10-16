
//
//  Coordinator.swift
//  demo-bambuser
//
//  Created by Nuno Patraquim on 15/10/2025.
//

import UIKit

protocol Coordinator {

    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
