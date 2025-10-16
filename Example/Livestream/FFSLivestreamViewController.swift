//
//  FFSLivestreamViewController.swift
//  demo-bambuser
//
//  Created by Nuno Patraquim on 15/10/2025.
//

import BambuserCommerceSDK
import UIKit

protocol FFSLivestreamControllable: UIViewController {

    var isPipActive: Bool { get }
    var videoID: String { get }

    func play()
    func stopPip()
}

final class FFSLivestreamViewController: UIViewController {

    let viewModel: FFSLivestreamViewModelProtocol

    private unowned var livestreamManager: FFSLivestreamPipHandling
    weak var navigator: FDKDismissalNavigationProtocol?

    private let bambuserPlayerView: BambuserPlayerView
    private let bambuserVideoPlayer: BambuserVideoPlayer

    private let livestreamView: FFSLivestreamView

    private var videoState: BambuserCommerceSDK.BambuserVideoState?

    init(
        viewModel: FFSLivestreamViewModelProtocol,
        livestreamManager: FFSLivestreamPipHandling
    ) {

        self.viewModel = viewModel
        self.livestreamManager = livestreamManager

        let bambuserVideoPlayer = BambuserVideoPlayer(server: .EU)
        self.bambuserVideoPlayer = bambuserVideoPlayer

        let playerView = bambuserVideoPlayer.createPlayerView(
            videoConfiguration: self.viewModel.playerConfiguration
        )

        self.bambuserPlayerView = playerView
        self.livestreamView = FFSLivestreamView(playerView: playerView)

        super.init(nibName: nil, bundle: nil)

        self.bambuserPlayerView.delegate = self
        self.bambuserPlayerView.pipController?.delegate = self
        self.livestreamView.delegate = self
        self.viewModel.delegate = self

        self.bambuserPlayerView.pipController?.isEnabled = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    deinit {

        let bambuserPlayerView = self.bambuserPlayerView

        Task { @MainActor in

            bambuserPlayerView.cleanup()
        }
    }
}

// MARK: - Lifecycle
extension FFSLivestreamViewController {

    override func loadView() {

        self.view = self.livestreamView
    }

    override func viewDidLoad() {

        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension FFSLivestreamViewController: FFSLivestreamControllable {

    var videoID: String { self.viewModel.videoID }

    var isPipActive: Bool { self.bambuserPlayerView.pipController?.isActive == true }

    func play() {

        self.bambuserPlayerView.play()
    }

    func stopPip() {

        self.bambuserPlayerView.pipController?.stop()
    }
}

// MARK: - FFSLivestreamViewDelegate
extension FFSLivestreamViewController: FFSLivestreamViewDelegate {

    func didTapMinimizeButton() {

        self.startPictureInPicture(completion: nil)
    }

    func didTapCloseButton() {

        self.livestreamManager.stopObservePip()
        self.navigator?.dismissModalNavigation(completion: nil)
    }
}

// MARK: - FFSLivestreamDelegate
extension FFSLivestreamViewController: FFSLivestreamViewModelDelegate {

    func openURL(with url: URL) { }
    func showProductListing() { }
    func showProductDetail(productId: Int) { }
}

// MARK: - Private methods
private extension FFSLivestreamViewController {

    func startPictureInPicture(completion: (() -> Void)?) {

        self.livestreamManager.startObservePip(from: self)

        self.bambuserPlayerView.pipController?.start()

        // Should dismiss the view controller to avoid an empty view during PiP
        self.navigator?.dismissModalNavigation(completion: completion)
    }
}

// MARK: - BambuserVideoPlayerDelegate
extension FFSLivestreamViewController: BambuserVideoPlayerDelegate {

    func onVideoStatusChanged(_ id: String, state: BambuserCommerceSDK.BambuserVideoState) {

        print("BAMBUSER onVideoStatusChanged \(state)")

        self.videoState = state
    }

    func onNewEventReceived(_ id: String, event: BambuserCommerceSDK.BambuserEventPayload) {

        self.viewModel.handleEvent(event)
    }

    func onErrorOccurred(_ id: String, error: any Error) { }

    func onVideoProgress(_ id: String, duration: Double, currentTime: Double) { }
}

// MARK: - BambuserPictureInPictureDelegate
extension FFSLivestreamViewController: BambuserPictureInPictureDelegate {

    func onPictureInPictureStateChanged(_ id: String, state: BambuserCommerceSDK.PlayerPipState) {

        print("BAMBUSER onPictureInPictureStateChanged \(state)")

        switch state {

        case .willStart:
            self.startPictureInPicture(completion: nil)

        case .restored:
            self.livestreamManager.recoverFromPiP()

        case .started,
             .willStop,
             .stopped:
            break

        @unknown default:
            break
        }
    }
}
