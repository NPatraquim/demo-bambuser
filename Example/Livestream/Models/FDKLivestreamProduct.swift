//
//  FDKLivestreamProduct.swift
//  demo-bambuser
//
//  Created by Nuno Patraquim on 15/10/2025.
//

import Foundation

public struct FDKLivestreamProduct {

    public let productId: Int
    public let providerId: String

    public init(
        productId: Int,
        providerId: String
    ) {

        self.productId = productId
        self.providerId = providerId
    }
}

extension FDKLivestreamProduct: Equatable { }
