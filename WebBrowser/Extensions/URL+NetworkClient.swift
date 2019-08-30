//
//  URL+NetworkClient.swift
//  WebBrowser
//
//  Created by Steve Chung on 2019-08-19.
//  Copyright © 2019 Steve Chung. All rights reserved.
//

import Foundation

/**
 * Helper methods to appending key/value parameters to the URL. 
 */
extension URL {
    
    func appendingParameters(_ parameters: NetworkParameters) throws -> URL {
        guard !parameters.isEmpty else {
            return self
        }
        
        let queryItems: [URLQueryItem] = parameters.map { key, value in
            return URLQueryItem(name: key, value: value)
        }
        
        return try appendingQueryItems(queryItems)
    }
    
    func appendingQueryItems(_ items: [URLQueryItem]) throws -> URL {
        
        guard !items.isEmpty else {
            return self
        }
        
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL(urlString:absoluteString)
        }
        
        let existingQueryItems = components.queryItems ?? []
        let newQueryItems = existingQueryItems + items
        components.queryItems = newQueryItems
        
        if let url = components.url {
            return url
        } else {
            throw NetworkError.invalidURL(urlString: components.url?.absoluteString ?? "")
        }
    }
}
