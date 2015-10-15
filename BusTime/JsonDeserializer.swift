//
//  JsonDeserializer.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/15/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
public func toStop (json: JSON) -> Stop {

}
*/

public func toConnection (json: JSON) -> Connection {
    return Connection(
        tripShortName: json["tripShortName"].string!,
        tripHeadSign: json["tripHeadSign"].string!,
        departure: toNSDate(json["departure"].string!))
}

// Parse departure date, time and timezone as NSDate
public func toNSDate(completeDepartureString: String) -> NSDate {
    let rangeLeftBracket = completeDepartureString.rangeOfString("[")!
    let indexLeftBracket = rangeLeftBracket.indexOf(rangeLeftBracket.first!)!
    let departureDateTimeString = completeDepartureString.substringToIndex(indexLeftBracket)
    var completeDepartureStringWithoutRightBracket = completeDepartureString.copy() as! String
    completeDepartureStringWithoutRightBracket.removeAtIndex(completeDepartureString.endIndex.predecessor())
    let departureTimezone = completeDepartureStringWithoutRightBracket.substringFromIndex(indexLeftBracket.successor())
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.timeZone = NSTimeZone(abbreviation: departureTimezone)
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return dateFormatter.dateFromString(departureDateTimeString)!
}