//
//  FFSLivestreamManager.swift
//  demo-bambuser
//
//  Created by Nuno Patraquim on 15/10/2025.
//

import Foundation
import UIKit

protocol FFSLivestreamNavigationHandling {

    func performLivestreamNavigation(
        videoID: String,
        completion: @escaping (Bool) -> Void
    )
}

protocol FFSLivestreamPipHandling: AnyObject {

    func startObservePip(from controller: FFSLivestreamControllable)
    func stopObservePip()
    func recoverFromPiP()
}

final class FFSLivestreamManager {

    weak var navigator: FDKLivestreamNavigationProtocol?

    private var liveStreamController: FFSLivestreamControllable?
}

extension FFSLivestreamManager: FFSLivestreamPipHandling {

    func startObservePip(
        from controller: FFSLivestreamControllable
    ) {

        self.liveStreamController = controller
    }

    func stopObservePip() {

        self.liveStreamController = nil
    }

    func recoverFromPiP() {

        self.recoverFromPiP(programatically: false)
    }

    private func recoverFromPiP(programatically: Bool = false) {

        guard let liveStreamController else { return }

        if programatically { liveStreamController.stopPip() }

        self.navigator?.navigateToLivestreamViewControllerFromPip(
            controller: self.liveStreamController
        )

        self.liveStreamController = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            liveStreamController.play()
        }
    }
}

// MARK: - Deeplink Navigation

extension FFSLivestreamManager: FFSLivestreamNavigationHandling {

    func performLivestreamNavigation(
        videoID: String,
        completion: @escaping (Bool) -> Void
    ) {

        if let liveStreamController,
           liveStreamController.isPipActive,
           liveStreamController.videoID == videoID {

            self.recoverFromPiP(programatically: true)
            return

        } else if self.liveStreamController != nil {

            self.liveStreamController = nil
        }

        self.navigator?.navigateToLivestreamViewController(videoID: videoID)
    }
}
