//
//  FFSLivestreamView.swift
//  demo-bambuser
//
//  Created by Nuno Patraquim on 15/10/2025.
//

import Foundation
import UIKit

public protocol FFSLivestreamViewDelegate: AnyObject {

    func didTapMinimizeButton()
    func didTapCloseButton()
}

final class FFSLivestreamView: UIView {

    // MARK: Public properties
    weak var delegate: FFSLivestreamViewDelegate?

    // MARK: Private properties
    private(set) var playerView: UIView

    private enum Constants {

        static let buttonBackgroundSize: CGFloat = 36.0
        static let buttonBackgroundAlpha: CGFloat = 0.5
    }

    private lazy var minimizeButton: UIButton = {

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.down")

        let button = UIButton(
            configuration: config,
            primaryAction: nil
        )
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(didTapMinimizeButton), for: .touchUpInside)

        return button
    }()

    private lazy var closeButton: UIButton = {

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")

        let button = UIButton(
            configuration: config,
            primaryAction: nil
        )
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)

        return button
    }()

    private let buttonsStackView: UIStackView = {

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.backgroundColor = .clear
        stackView.spacing = 12.0
        stackView.layoutMargins = UIEdgeInsets(
            top: .zero,
            left: 16.0,
            bottom: .zero,
            right: 16.0
        )

        return stackView
    }()

    init(playerView: UIView) {

        self.playerView = playerView
        super.init(frame: CGRect.zero)
        self.configureView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Actions

private extension FFSLivestreamView {

    @objc
    func didTapMinimizeButton() {
        self.delegate?.didTapMinimizeButton()
    }

    @objc
    func didTapCloseButton() {
        self.delegate?.didTapCloseButton()
    }
}

// MARK: - Layout

private extension FFSLivestreamView {

    func configureView() {

        self.addSubviews()
        self.defineSubviewConstraints()
    }

    func addSubviews() {

        self.addSubview(self.playerView)
        self.addSubview(self.buttonsStackView)

        let closeButtonView = Self.buttonBackgroundView()
        closeButtonView.addSubview(self.closeButton)

        let minimizeButtonView = Self.buttonBackgroundView()
        minimizeButtonView.addSubview(self.minimizeButton)

        self.buttonsStackView.addArrangedSubview(closeButtonView)
        self.buttonsStackView.addArrangedSubview(minimizeButtonView)
    }

    func defineSubviewConstraints() {

        self.playerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.playerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.buttonsStackView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            self.buttonsStackView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: 6.0),

            self.closeButton.centerXAnchor.constraint(equalTo: self.closeButton.superview?.centerXAnchor ?? self.centerXAnchor),
            self.closeButton.centerYAnchor.constraint(equalTo: self.closeButton.superview?.centerYAnchor ?? self.centerYAnchor),

            self.minimizeButton.centerXAnchor.constraint(equalTo: self.minimizeButton.superview?.centerXAnchor ?? self.centerXAnchor),
            self.minimizeButton.centerYAnchor.constraint(equalTo: self.minimizeButton.superview?.centerYAnchor ?? self.centerYAnchor)
        ])
    }

    static func buttonBackgroundView() -> UIView {

        let buttonBackgroundView = UIView(frame: CGRect.zero)
        buttonBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        buttonBackgroundView.widthAnchor.constraint(equalToConstant: Constants.buttonBackgroundSize).isActive = true
        buttonBackgroundView.heightAnchor.constraint(equalToConstant: Constants.buttonBackgroundSize).isActive = true

        buttonBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(Constants.buttonBackgroundAlpha)
        buttonBackgroundView.layer.cornerRadius = Constants.buttonBackgroundSize / 2.0

        return buttonBackgroundView
    }
}
