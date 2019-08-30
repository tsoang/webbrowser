//
//  SearchEngine.swift
//  WebBrowser
//
//  Created by Steve Chung on 2019-08-19.
//  Copyright © 2019 Steve Chung. All rights reserved.
//

import Foundation

/**
 * This is an interface for the Search API.
 * The app can use this interface instead of using Bing directly.
 * By using a factory method to create the concreate SearchAPI class, it can be anything
 * such as GoogleAPI, DuckDuckGoAPI, or a dumpy SearchAPI for unit testing.
 */

typealias SearchSuggestionResponse = (searchText: String, suggestions: [String])
typealias SearchSuggestionCompletion = (SearchSuggestionResponse?, Error?) -> Void

enum SearchAPIError: Error, LocalizedError {
    case searchQueryURLError(urlString: String)
    case searchSuggestionURLError(urlString: String)
    case invalidSearchSuggestionResponseData
    
    var errorDescription: String? {
        switch self {
        case .searchQueryURLError(let urlString):
            return "Search engine query URL error: \(urlString)"
        case .searchSuggestionURLError(let urlString):
            return "Search engine suggestion URL error: \(urlString)"
        case .invalidSearchSuggestionResponseData:
            return "Invliad search suggestion response data."
        }
    }
}

protocol SearchAPI {
    func searchURLWithQuery(_ query: String) throws -> URL
    func suggestionsForText(_ text: String, completion: @escaping SearchSuggestionCompletion) throws
}

