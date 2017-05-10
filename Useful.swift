//
//  Useful.swift
//  app
//
//  Created by Adrien morel on 08/03/2017.
//  Copyright © 2017 ZiggTime. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import PromiseKit
import SwiftyJSON

class Useful {
    
    class ApiGetter {
        
        public var endpoint: String!
        public var params: Parameters!
        
        public func get() -> Promise<JSON> {
            return Api.instance.get(endpoint, withParams: params)
        }
    }
    
    public typealias Callback = () -> ()
    
    public static func colorFromHex(_ color: Int) -> UIColor {
        
        let colorF = Float(color)
        let red = colorF / 0x10000
        let green = (colorF.truncatingRemainder(dividingBy: 0x10000)) / 0x100
        let blue = colorF.truncatingRemainder(dividingBy: 0x100)
        return UIColor(colorLiteralRed: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
    static func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    static func makeGetObj(_ endpoint: String, params: Parameters) -> ApiGetter {
        let getter = ApiGetter()
        getter.endpoint = endpoint
        getter.params = params
        return getter
    }
    
    static func delayToString(_ date: Date) -> String {
        return "\(date.timeIntervalSinceNow)"
    }
    
    
    static func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    
}

extension String {
    
    func index(character chr: Character) -> Int {
        
        var index = 0
        for c in self.characters {
            if c == chr {
                return index
            }
            index += 1
        }
        return index
    }
}

