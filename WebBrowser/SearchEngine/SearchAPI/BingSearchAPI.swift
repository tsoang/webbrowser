//
//  BingSearchAPI.swift
//  WebBrowser
//
//  Created by Steve Chung on 2019-08-19.
//  Copyright © 2019 Steve Chung. All rights reserved.
//

import Foundation

/**
 * A concrete class of the SearchAPI interface.
 */
final class BingSearchAPI: SearchAPI {
    
    // MARK: - Private Constants
    // Normally we would design a switch mechanism for production and staging server URL.
    // Such as using a configuration macro, configuration plist file, scheme, or target.
    private let searchSuggestionURLString: String = "https://api.bing.com/osjson.aspx"
    private let searchQueryURLString: String = "https://www.bing.com/search"
    
    
    // MARK: - Private Enums
    private enum SearchParameterKeys: String {
        case suggestionKey  = "query"
        case queryKey = "q"
    }
    
    
    // MARK: - Private Properties
    private let networkClient: NetworkClient
    private var networkTask: URLSessionDataTask?
    
    
    // MARK: - Constructors
    /**
     * Constructor with dependency injection for the NetworkClient
     * If we want to switch to a different NetworkClient such as dumpy NetworkClient for unit testing.
     */
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    
    // MARK: - Internal Methods
    func searchURLWithQuery(_ query: String) throws -> URL {
        return try searchQueryURL().appendingParameters([SearchParameterKeys.queryKey.rawValue:query])
    }
    
    func suggestionsForText(_ text: String, completion: @escaping SearchSuggestionCompletion) throws {
        networkTask?.cancel()
        
        let parameters = [SearchParameterKeys.suggestionKey.rawValue:text]
        let method = HTTPMethod.get.rawValue
        let networkRequest = try networkClient.makeNetworkRequest(urlString: searchSuggestionURLString, parameters: parameters, method: method)
        
        networkTask = try networkClient.request(networkRequest) { networkResponse in

            guard networkResponse.error == nil else {
                completion(nil, networkResponse.error)
                return
            }
            
            guard let responseData = networkResponse.response else {
                completion(nil, nil)
                return
            }
            
            do {
                let searchSuggestionResponse = try BingSearchAPI.parseNetworkResponseData(responseData)
                completion(searchSuggestionResponse, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    
    // MARK: - Private Methods
    private class func parseNetworkResponseData(_ responseData: NetworkResponseData) throws -> SearchSuggestionResponse {
        
        if let responseArray = responseData as? [Any] {
            if let searchText = responseArray.first as? String {
                if responseArray.count >= 2, let suggestions = responseArray[1] as? [String] {
                    return SearchSuggestionResponse(searchText:searchText, suggestions:suggestions)
                }
            }
        }
        
        throw SearchAPIError.invalidSearchSuggestionResponseData
    }
    
    private func searchQueryURL() throws -> URL {
        if let url = URL(string:searchQueryURLString) {
            return url
        } else {
            throw SearchAPIError.searchQueryURLError(urlString: searchQueryURLString)
        }
    }
    
}
