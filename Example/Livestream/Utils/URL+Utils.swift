//
//  URL+Utils.swift
//  demo-bambuser
//
//  Created by Nuno Patraquim on 15/10/2025.
//

import Foundation

public extension URL {

    static let farfetchDomain = "farfetch.com"
    static let farfetchUrlScheme = "farfetch://"

    var isFarfetchDomain: Bool {

        self.componentHost?.contains(URL.farfetchDomain) ?? false
    }

    var isFarfetchUrlScheme: Bool {

        self.absoluteString.hasPrefix(URL.farfetchUrlScheme)
    }
}

private extension URL {

    var componentHost: String? {

        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {

            return nil
        }

        return components.host
    }
}
