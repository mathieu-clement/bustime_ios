//
//  DateUtils.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/15/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import Foundation

public func minutesFromNow (date: NSDate) -> Int {
    return Int(NSInteger(date.timeIntervalSinceNow) / 60)
}