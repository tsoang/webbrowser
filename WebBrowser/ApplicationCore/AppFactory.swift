//
//  AppFactory.swift
//  WebBrowser
//
//  Created by Steve Chung on 2019-08-19.
//  Copyright © 2019 Steve Chung. All rights reserved.
//

import Foundation

/**
 * A factory design pattern. With this design pattern, now we can insert logic
 * to create different SearchAPI or NetworkClient by using a config file, UserDefaults, etc.
 */
final class AppFactory {
    
    class func makeSearchAPI() -> SearchAPI {
        return BingSearchAPI(networkClient: makeNetworkClient())
    }
    
    class func makeNetworkClient() -> NetworkClient {
        return HTTPClient()
    }
}
