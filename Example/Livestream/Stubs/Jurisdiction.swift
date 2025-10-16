//
//  Jurisdiction.swift
//  demo-bambuser
//
//  Created by Nuno Patraquim on 15/10/2025.
//

import Foundation

protocol JurisdictionProtocol {

    var countryCulture: String { get }
    var currencyCode: String { get }
}

struct Jurisdiction: JurisdictionProtocol {

    var countryCulture: String = "en-US"
    var currencyCode: String = "USD"
}
