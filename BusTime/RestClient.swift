//
//  RestClient.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/15/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

private let BASE_URL = "http://clement.gotdns.ch:9000"

private func get(path: String, parameters: [String: AnyObject]? = nil,
    onSuccess: ((result:JSON) -> Void)? = nil,
    onFailure: ((error:NSError?) -> Void)? = nil) {
        let url = "\(BASE_URL)\(path)"
        NSLog("Preparing for GET request to: \(url)")
        
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON { response in
                NSLog("GET Raw Result: \(response.result.value)")
                if response.result.isFailure {
                    NSLog("GET Error: \(response.result.error!)")
                    
                    if onFailure != nil {
                        onFailure!(error: response.result.error)
                    }
                }
                else {
                    let json = JSON(response.result.value!)
                    NSLog("GET JSON Result: \(json)")
                    
                    if onSuccess != nil {
                        onSuccess!(result: json)
                    }
                }
        }
}

public func getClosestStops (latitude latitude: Float, longitude: Float, maxRadius: Int? = nil,
    onSuccess: ((result:JSON) -> Void)? = nil,
    onFailure: ((error:NSError?) -> Void)? = nil) {
        var parameters : [String: AnyObject] = ["latitude": latitude, "longitude": longitude]
        if maxRadius != nil {
            parameters["maxDist"] = maxRadius!
        }
        get("/stops/closest", parameters: parameters, onSuccess: onSuccess, onFailure: onFailure)
}

public func getNextBuses (stopId stopId: String, maxMinutes: Int?,
    onSuccess: ((result:JSON) -> Void)? = nil,
    onFailure: ((error:NSError?) -> Void)? = nil) {
        var parameters = [String: AnyObject]()
        if maxMinutes != nil {
            parameters["maxMinutes"] = maxMinutes!
        }
        get("/connections/buses/next/\(stopId)", parameters: parameters, onSuccess: onSuccess, onFailure: onFailure)
}