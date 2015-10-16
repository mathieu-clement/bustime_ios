//
//  ViewController.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/15/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        getNextBuses(stopId: "8587793", maxMinutes: 1440,
            onSuccess: { (resultarray) -> Void in
                for (_,result) in resultarray {
                    let connection = toConnection(result)
                    
                    let futureDate = connection.departure
                    let differenceInMinutes = minutesFromNow(futureDate)
                    
                    print(connection)
                    print("That's in \(differenceInMinutes) minutes")
                }
            }, onFailure: { (error) -> Void in
                print("Error retrieving next buses: \(error)")
        })
        
        getClosestStops(latitude: 46.755559, longitude: 7.152352, maxRadius: 1000,
            onSuccess: { (resultarray) -> Void in
                for (_,result) in resultarray {
                    let stop = toStop(result)
                    print(stop)
                }
                
            }, onFailure: { (error) -> Void in
                print("Error retrieving closest stops: \(error)")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveResult(results: JSON) {
        
    }
    
    
}

