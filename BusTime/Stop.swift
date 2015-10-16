//
//  Stop.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/15/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import Foundation

public struct Stop {
    let id : String
    let stopName : String
    let platformCode : String?
    let latitude : Float
    let longitude : Float
    let distance : Int
}