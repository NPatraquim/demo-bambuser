//
//  FFSLivestreamViewModel.swift
//  demo-bambuser
//
//  Created by Nuno Patraquim on 15/10/2025.
//

import BambuserCommerceSDK
import Foundation

protocol FFSLivestreamViewModelProtocol: AnyObject {

    var videoID: String { get }

    var delegate: FFSLivestreamViewModelDelegate? { get set }
    var playerConfiguration: BambuserVideoConfiguration { get }
    var settings: FFSLivestreamSettings { get }

    func handleEvent(_ event: BambuserEventPayload)
}

protocol FFSLivestreamViewModelDelegate: AnyObject {

    func openURL(with url: URL)
    func showProductDetail(productId: Int)
    func showProductListing()
}

final class FFSLivestreamViewModel: FFSLivestreamViewModelProtocol {

    // MARK: Constants
    private enum Constants {

        static let actionOriginKey = "actionOrigin"
        static let eventKey = "event"
        static let idKey = "id"
        static let productsKey = "products"
        static let refKey = "ref"
        static let urlKey = "url"

        static let farfetchUrlScheme = "farfetch://"
    }

    let settings: FFSLivestreamSettings
    let jurisdiction: JurisdictionProtocol

    var livestreamProducts = [FDKLivestreamProduct]()

    weak var delegate: FFSLivestreamViewModelDelegate?

    /// Returns a `BambuserVideoConfiguration` which is used to create a `BambuserPlayerView` in Bambuser setup.
    var playerConfiguration: BambuserVideoConfiguration {

        return BambuserVideoConfiguration(
            type: .live(id: self.settings.videoID),
            configuration: [
                "buttons": [
                    "dismiss": "none"
                ],
                "ui": [
                    "hideCartView": !self.settings.isCartViewEnabled,
                    "hideCartButton": !self.settings.isCartButtonEnabled,
                    "hideChatOverlay": !self.settings.isChatOverlayEnabled,
                    "hideProductList": !self.settings.isProductListEnabled,
                    "hideProductView": !self.settings.isProductDetailEnabled,
                    "hideShareButton": !self.settings.isShareButtonEnabled
                ],
                "autoplay": self.settings.isAutoPlayEnabled,
                "currency": self.jurisdiction.currencyCode,
                "locale": self.jurisdiction.countryCulture
            ]
        )
    }

    var videoID: String { self.settings.videoID }

    init(
        settings: FFSLivestreamSettings,
        jurisdiction: JurisdictionProtocol
    ) {

        self.settings = settings
        self.jurisdiction = jurisdiction
    }
}

extension FFSLivestreamViewModel {

    func handleEvent(_ event: BambuserEventPayload) {

        self.handleEvent(
            type: event.type,
            data: event.data
        )
    }
}

extension FFSLivestreamViewModel {

    //unit testing
    func handleEvent(
        type: String,
        data: [String: any Sendable]
    ) {

        switch type {

        case "action-card-clicked": self.openExternalURL(from: data)
        case "provide-product-data": self.provideProductData(from: data)
        case "should-show-product-list": self.showProductList()
        case "should-show-product-view": self.showProductView(from: data)

        default:
            break
        }
    }

    func openExternalURL(from data: [String: any Sendable]) {

        guard let urlPayloadData = data[Constants.eventKey] as? [String: Any],
              var urlValue = urlPayloadData[Constants.urlKey] as? String else {

            assertionFailure("Livestream failed to retrieve url from the action-card-clicked event")
            return
        }

        if let range = urlValue.range(of: Constants.farfetchUrlScheme) {

            urlValue = String(urlValue[range.lowerBound...])
        }

        guard let url = URL(string: urlValue) else { return }

        self.delegate?.openURL(with: url)
    }

    func provideProductData(from data: [String: any Sendable]) {

        guard let productsPayloadData = data[Constants.eventKey] as? [String: Any],
              let products = productsPayloadData[Constants.productsKey] as? [[String: String]] else {

            assertionFailure("Livestream failed to retrieve products from the provide-product-data event")
            return
        }

        self.livestreamProducts = products.compactMap { self.livestreamProduct(with: $0) }
    }

    func showProductView(from data: [String: any Sendable]) {

        guard let productPayloadData = data[Constants.eventKey] as? [String: Any],
              let id = productPayloadData[Constants.idKey] as? String else {

            return
        }

        guard let product = self.livestreamProducts.first(where: { $0.providerId == id }) else {

            assertionFailure("Livestream failed to get product to navigate to PDP")
            return
        }

        self.delegate?.showProductDetail(productId: product.productId)
    }

    func showProductList() {

        self.delegate?.showProductListing()
    }

    func livestreamProduct(with product: [String: String]) -> FDKLivestreamProduct? {

        guard let providerId = product[Constants.idKey],
              let productIdString = product[Constants.refKey],
              let productId = Int(productIdString) else {

            return nil
        }

        return FDKLivestreamProduct(
            productId: productId,
            providerId: providerId
        )
    }
}
