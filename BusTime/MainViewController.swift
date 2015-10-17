//
//  ViewController.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/15/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import XCGLogger

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    let restClient = RestClient()
    var alerts = Alerts!()
    
    var closestStops = [Stop]()
    var currentStop : Stop? {
        set(newVal) {
            (parentViewController as! BTNavigationController).currentStop = newVal
        }
        get {
            return (parentViewController as! BTNavigationController).currentStop
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var activityIndicatorText: UILabel!
    
    @IBOutlet weak var busStopLabel: UILabel!
    
    @IBOutlet weak var busStopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        alerts = Alerts(viewController: self)
        
        activityIndicator.hidden = true
        activityIndicatorText.hidden = true
        
        /*
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
        */
        
        
        startProgress("Looking for bus stops nearby")
        
        LOCATION_MANAGER.delegate = self
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Restricted ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
                LOG.error("Location is disabled. Showing error message and exiting.")
        } else if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            LOCATION_MANAGER.requestWhenInUseAuthorization()
        } else {
            onLocationAuthorized()
        }
        
    }
    
    @IBAction func onBusStopButtonTouchedUpInside() {
        performSegueWithIdentifier("pickStop", sender: busStopButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pickStop" {
            let pickStopViewCtrl = segue.destinationViewController as! StopPickerViewController
            pickStopViewCtrl.stops = closestStops
        }
    }
    
    func onLocationKnown(location: CLLocationCoordinate2D) {
        restClient.getClosestStops(
            latitude: Float(location.latitude),
            longitude: Float(location.longitude),
            maxRadius: 2000,
            onSuccess: { (resultarray) -> Void in
                self.stopProgress()
                self.closestStops.removeAll()
                for (_,result) in resultarray {
                    let stop = toStop(result)
                    LOG.debug("\(stop)")
                    self.closestStops.append(stop)
                }
                
                if !self.closestStops.isEmpty {
                    self.currentStop = self.closestStops.first!
                } else {
                    LOG.info("No stops nearby")
                }
                
            }, onFailure: { (error) -> Void in
                self.stopProgress()
                // TODO What if there are no bus stops nearby? Try extending range automatically or warn user.
        })
    }
    
    func onLocationAuthorized() {
        LOCATION_MANAGER.desiredAccuracy = 200
        LOCATION_MANAGER.distanceFilter = 100
        LOCATION_MANAGER.requestLocation()
    }
    
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.Denied && status != CLAuthorizationStatus.Restricted {
            onLocationAuthorized()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last;
        if userLocation != nil {
            onLocationKnown(userLocation!.coordinate)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        LOG.error("Could not determine location due to \(error).")
        alerts.displayNoLocation { () -> Void in
            LOCATION_MANAGER.requestLocation()
        }
    }
    
    func refreshStopName() {
        busStopLabel.text = currentStop?.stopName
    }
    
    func startProgress(text: String) {
        activityIndicator.hidden = false
        activityIndicatorText.text = text
        activityIndicatorText.hidden = false
        activityIndicator.startAnimating()
    }
    
    func stopProgress() {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        activityIndicatorText.hidden = true
    }
    
    
}

