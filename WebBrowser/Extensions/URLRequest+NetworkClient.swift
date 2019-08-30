//
//  URLRequest+NetworkClient.swift
//  WebBrowser
//
//  Created by Steve Chung on 2019-08-19.
//  Copyright © 2019 Steve Chung. All rights reserved.
//

import Foundation

extension URLRequest {
    
    init(networkRequest: NetworkRequest) throws {
        
        var url = networkRequest.url
        if let parameters = networkRequest.parameters {
            url = try networkRequest.url.appendingParameters(parameters)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = networkRequest.method
        
        self = request
    }
}
