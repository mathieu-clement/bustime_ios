//
//  Connection.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/15/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import Foundation

public struct Connection {
    let tripShortName : String
    let tripHeadSign : String
    let departure : NSDate
    
    // Precondition: connections already appear sorted by trip short name as desired
    static func groupByTripShortName(connections: [Connection]) -> OrderedDictionary<String, [Connection]> {
        var connectionsByTripShortName = OrderedDictionary<String, [Connection]>()
        for connection in connections {
            if connectionsByTripShortName.keys.contains(connection.tripShortName) {
                connectionsByTripShortName[connection.tripShortName]?.append(connection)
            } else {
                connectionsByTripShortName[connection.tripShortName] = [connection]
            }
        }
        
        // Now, for each trip sort by departure time
        
        for tripShortName in connectionsByTripShortName.keys {
            connectionsByTripShortName[tripShortName]!.sortInPlace({
                (conn1: Connection, conn2: Connection) -> Bool in
                return conn1.departure.compare(conn2.departure).rawValue < 0
            })
        }
        
        return connectionsByTripShortName
    }
}