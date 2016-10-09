//
//  APIManager.swift
//  Request
//
//  Created by Harish Gonnabhaktula on 17/09/16.
//  Copyright © 2016 Harish Gonnabattula. All rights reserved.
//

import UIKit
import Alamofire

class APIManager: NSObject, NSURLSessionDelegate {
    
    var session: NSURLSession?
    var Url: NSURL?
    var request: NSMutableURLRequest?
    var response: NSHTTPURLResponse?
    var URL:String = "http://www.google.com"
    var method = "GET"
    var headers:[String:String]? = nil
    var body:NSData? = nil
    var timeLine : Timeline?
    static var sharedInstance = APIManager()
    
    private override init() {}
    
    func setUp() {
        
        
        self.Url = NSURL(string: URL)
        
        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        
        request = NSMutableURLRequest(URL: self.Url!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
        
        request?.HTTPMethod = method
        
        request?.HTTPBody = body
        
        request?.allowsCellularAccess = true
        
        request?.allHTTPHeaderFields = headers
        
    }
    
    
    func httpRequest(completionHandler: (String, NSHTTPURLResponse?) -> Void) {
        
        
        Alamofire.request(request!).responseString { (response) in
            
            self.response = response.response
            self.timeLine = response.timeline
            completionHandler(response.result.value ?? "No data recieved", response.response)
        }
        
        
    }
    
    func reset() {
        
        session = nil
        Url = nil
        URL = "http://www.google.com"
        request = nil
        response = nil
        method = "GET"
        body = nil
        headers = nil
    }
    

}
