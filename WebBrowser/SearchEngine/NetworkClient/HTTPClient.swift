//
//  HTTPClient.swift
//  WebBrowser
//
//  Created by Steve Chung on 2019-08-19.
//  Copyright © 2019 Steve Chung. All rights reserved.
//

import Foundation


let HTTPSuccessCodes = (200...299)

// I used an enum instead of a 'let' constant for future expension if we want to add post, put, delete, etc.
enum HTTPMethod: NetworkMethod {
    case get = "GET"
}

// I used an enum instead of a 'let' constant for future expension if we want to add text, xml, etc.
enum HTTPMineType: String {
    case json = "application/json"
}

struct HTTPRequest: NetworkRequest {
    let url: URL
    let parameters: NetworkParameters?
    let method: NetworkMethod
}

struct HTTPResponse: NetworkResponse {
    let request: NetworkRequest
    let response: NetworkResponseData?
    let error: Error?
}


/**
 * This is a concrete class of NetworkClient interface.
 * It is responsible for making HTTP network calls and network data validation
 */
final class HTTPClient: NetworkClient {
    
    func request(_ networkRequest: NetworkRequest, completion: @escaping NetworkRequestCompletion) throws -> URLSessionDataTask {
        let request = try URLRequest(networkRequest: networkRequest)
        let sessionTask = URLSession.shared.dataTask(with: request) { data, response, error in

            guard error == nil else {
                var newError = error
                if (error as NSError?)?.code == NSURLErrorCancelled {
                    newError = nil
                }
                
                DispatchQueue.main.async {
                    completion(HTTPResponse(request:networkRequest, response:nil, error:newError))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, HTTPSuccessCodes.contains(httpResponse.statusCode) else {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = NetworkError.serverError(statusCode: response.statusCode)
                } else {
                    error = NetworkError.invalidResponseObject
                }
                
                DispatchQueue.main.async {
                    completion(HTTPResponse(request:networkRequest, response:nil, error:error))
                }
                
                return
            }
            
            guard let mime = httpResponse.mimeType, mime == HTTPMineType.json.rawValue else {
                DispatchQueue.main.async {
                    completion(HTTPResponse(request:networkRequest,
                                            response:nil,
                                            error:NetworkError.incorrectReturnedDataType(returnType:httpResponse.mimeType ?? "")))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(HTTPResponse(request:networkRequest, response:nil, error:nil))
                }
                return
            }
            
            // Could use a transformer to convert the data based on mime type.
            // But using a simple switch statement here due to time constrain.
            var response: NetworkResponseData? = data
            switch mime {
            case HTTPMineType.json.rawValue:
                response = try? JSONSerialization.jsonObject(with: data, options: [])
            default:
                break
            }
            
            DispatchQueue.main.async {
                completion(HTTPResponse(request:networkRequest, response:response, error:error))
            }
        }
        sessionTask.resume()
        return sessionTask
    }
    
    func makeNetworkRequest(urlString: String, parameters: NetworkParameters, method: NetworkMethod) throws -> NetworkRequest {

        guard let url = URL(string:urlString) else {
            throw NetworkError.invalidURL(urlString: urlString)
        }
        
        return HTTPRequest(url:url, parameters:parameters, method:method)
    }
}
