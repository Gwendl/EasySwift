//
//  Api.swift
//  app
//
//  Created by Adrien morel on 25/02/2017.
//  Copyright © 2017 ZiggTime. All rights reserved.
//

import Foundation
import Contacts
import SwiftyJSON
import PromiseKit
import Alamofire

class Api {
    
    
    static let instance = Api()
    
    var authServerUrl = "http://api.ziggtime.com:4000"
    var serverUrl = "http://api.ziggtime.com:4001"
    
    init() {
        
        if ProcessInfo.processInfo.environment["ENV"] == "DEBUG" {
            
            serverUrl = "http://193.70.42.87:4001"
            authServerUrl = "http://193.70.42.87:4000"
        }
    }
    
    var accessToken: String? = UserDefaults.standard.string(forKey: "accessToken") {
        didSet {
            UserDefaults.standard.set(accessToken, forKey: "accessToken")
        }
    }
    
    class BackendError: Error {
        let json: JSON
        
        init(_ json: JSON) {
            self.json = json
        }
    }
    
    public func clearAccessToken() {
        accessToken = nil
        UserDefaults.standard.removeObject(forKey: "accessToken")
    }
    
    func request(_ endpoint: String, withParams params: Parameters, method: HTTPMethod) -> Promise<JSON> {
        
        return Promise { fulfill, reject in
            
            var headers = HTTPHeaders()
            if let token = accessToken {
                headers["Authorization"] = "Bearer \(token)"
            }
            if let deviceToken = App.instance.deviceToken {
                headers["DeviceToken"] = deviceToken
            }
            
            let c = Alamofire.request(Api.instance.serverUrl + endpoint, method: method, parameters: params, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: headers)
                .validate()
                .responseJSON() { response in
                    switch response.result {
                    case .success(let json):
                        fulfill(JSON(json))
                    case .failure(let error):
                        if let err = error as? AFError {
                            if err.isResponseSerializationError {
                                fulfill(JSON.null)
                            } else {
                                reject(error)
                            }
                        }
                    }
            }
            print(c.debugDescription)
        }
    }
    
    func post(_ endpoint: String, withParams params: Parameters) -> Promise<JSON> {
        return request(endpoint, withParams: params, method: .post)
    }
    
    func delete(_ endpoint: String, withParams params: Parameters) -> Promise<JSON> {
        return request(endpoint, withParams: params, method: .delete)
    }
    
    func put(_ endpoint: String, withParams params: Parameters) -> Promise<JSON> {
        return request(endpoint, withParams: params, method: .put)
    }
    
    func get(_ endpoint: String, withParams params: Parameters) -> Promise<JSON> {
        return request(endpoint, withParams: params, method: .get)
    }
    
    func get(_ endpoint: String) -> Promise<JSON> {
        return get(endpoint, withParams: [:])
    }
    
    func authenticate(withToken token: String) -> Promise<()> {
        
        let saveServUrl = serverUrl
        serverUrl = authServerUrl
        let promise = Api.instance.post("/authorization/facebook", withParams: ["access_token": token])
            .then { res -> () in
                self.accessToken = res["access_token"].stringValue
        }
        serverUrl = saveServUrl
        return promise
    }
    
    func upload(_ endpoint: String, data: Data, contentType: String) -> Promise<()> {
        
        return Promise { fulfill, reject in
            let c = Alamofire.upload(data, to: serverUrl + endpoint, method: .put, headers: ["Content-Type": contentType])
                .validate()
                .responseString { response in
                    switch response.result {
                    case .success:
                        fulfill()
                    case .failure(let err):
                        print(String(data: response.data!, encoding: .utf8) ?? "nil")
                        reject(err)
                    }
            }
            print(c.debugDescription)
        }
    }
    
    static func Upload(_ url: String, data: Data, contentType: String) -> Promise<()> {
        let instance = Api()
        instance.serverUrl = url
        return instance.upload("", data: data, contentType: contentType)
    }
}
