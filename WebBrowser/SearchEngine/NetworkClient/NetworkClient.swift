//
//  NetworkClient.swift
//  WebBrowser
//
//  Created by Steve Chung on 2019-08-19.
//  Copyright © 2019 Steve Chung. All rights reserved.
//

import Foundation

/**
 * This is an interface for a NetworkClient responsible for making network calls,
 * retrieving raw data and passing it to the API layer for further process.
 */

typealias NetworkMethod = String
typealias NetworkParameters = [String:String]
typealias NetworkRequestCompletion = (NetworkResponse) -> Void
typealias NetworkResponseData = Any

enum NetworkError: Error, LocalizedError {
    case unkown
    case invalidURL(urlString: String)
    case invalidResponseObject
    case serverError(statusCode: Int)
    case incorrectReturnedDataType(returnType: String)
    
    var errorDescription: String? {
        switch self {
        case .unkown:
            return "Unknown network error."
        case .invalidURL(let urlString):
            return "Invalid URL: \(urlString)"
        case .invalidResponseObject:
            return "Invalid response object."
        case .serverError(let statusCode):
            return "Server error with code: \(statusCode)"
        case .incorrectReturnedDataType(let returnType):
            return "Incorrect returned data type: \(returnType)"
        }
    }
}

/**
 * This is the main network interface for requesting data and creating instances of other NetworkClient type
 */
protocol NetworkClient {
    func request(_ networkRequest: NetworkRequest, completion: @escaping NetworkRequestCompletion) throws -> URLSessionDataTask
    func makeNetworkRequest(urlString: String, parameters: NetworkParameters, method: NetworkMethod) throws -> NetworkRequest
}

/**
 * A data structure to hold all network request data.
 */
protocol NetworkRequest {
    var url: URL { get }
    var parameters: NetworkParameters? { get }
    var method: NetworkMethod { get }
}

/**
 * A data structure to hold all network response data. 
 */
protocol NetworkResponse {
    var request: NetworkRequest { get }
    var response: NetworkResponseData? { get }
    var error: Error? { get }
}
