//
//  URLExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

extension URL {
    static func mock(stringURL: String = "https://avid.avid.co") -> URL {
        guard let url = URL(string: stringURL) else {
            fatalError("mock URL is nil for stringURL: \(stringURL)")
        }
        return url
    }
}
