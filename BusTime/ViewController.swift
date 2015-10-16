//
//  ViewController.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/15/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import UIKit
import SwiftyJSON
import XCGLogger

class ViewController: UIViewController {
    
    let restClient = RestClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        restClient.getNextBuses(stopId: "8587793", maxMinutes: NEXT_BUSES_MAX_TIME,
            onSuccess: { (resultarray) -> Void in
                for (_,result) in resultarray {
                    let connection = toConnection(result)
                    
                    let futureDate = connection.departure
                    let differenceInMinutes = minutesFromNow(futureDate)
                    
                    LOG.debug("\(connection)")
                    LOG.verbose("That's in \(differenceInMinutes) minutes.")
                }
            }, onFailure: { (error) -> Void in
                
        })
        
        restClient.getClosestStops(latitude: 46.755559, longitude: 7.152352, maxRadius: 500,
            onSuccess: { (resultarray) -> Void in
                for (_,result) in resultarray {
                    let stop = toStop(result)
                    LOG.debug("\(stop)")
                }
                
            }, onFailure: { (error) -> Void in
                
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveResult(results: JSON) {
        
    }
    
    
}

