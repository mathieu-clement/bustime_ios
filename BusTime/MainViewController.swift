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

class MainViewController: UIViewController, CLLocationManagerDelegate, ConnectionsDelegate {
    
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
    
    @IBOutlet weak var departureTimesTableView: DepartureTimesTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        alerts = Alerts(viewController: self)
        
        activityIndicator.hidden = true
        activityIndicatorText.hidden = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshStop()
        startLookingForStopsNearby()
    }
    
    override func viewDidDisappear(animated: Bool) {
        LOCATION_MANAGER.stopUpdatingLocation()
        departureTimesTableView.stopRefreshingEveryMinute()
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
            maxRadius: NSUserDefaults.standardUserDefaults().integerForKey("maxRadius"),
            onSuccess: { (resultarray) -> Void in
                self.stopProgress()
                var newClosestStops = [Stop]()
                for (_,result) in resultarray {
                    let stop = toStop(result)
                    LOG.debug("\(stop)")
                    newClosestStops.append(stop)
                }
                
                if !newClosestStops.isEmpty {
                    self.busStopButton.enabled = newClosestStops.count > 1
                    
                    if self.currentStop != nil &&
                        self.closestStops.first! != self.currentStop! &&
                        newClosestStops.contains(self.currentStop!) {
                            // user hand picked a stop and it's still in the neighborhood
                    } else {
                        self.currentStop = newClosestStops.first!
                        self.refreshStop()
                    }
                    
                    self.closestStops = newClosestStops
                } else {
                    LOG.info("No stops nearby")
                    // TODO What if there are no bus stops nearby? Try extending range automatically or warn user.
                    self.busStopButton.enabled = false
                    self.currentStop = nil
                }
                
            }, onFailure: { (error) -> Void in
                self.stopProgress()
                // TODO Warn network error, retry / quit
        })
    }
    
    func onLocationAuthorized() {
        LOCATION_MANAGER.desiredAccuracy = 200
        LOCATION_MANAGER.distanceFilter = 300
        //LOCATION_MANAGER.requestLocation()
        LOCATION_MANAGER.startUpdatingLocation()
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
        busStopButton.enabled = false
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            alerts.displayNoLocation { () -> Void in
                //LOCATION_MANAGER.requestLocation()
            }
        }
    }
    
    func refreshStop(onSuccess pOnSuccess: ([Connection] -> Void)? = nil,
        onFailure pOnFailure: (AnyObject? -> Void)? = nil) {
            // Avoid displaying the previous schedule when the stop is changed
            departureTimesTableView.setConnections([Connection]())
            
            if currentStop != nil {
                busStopLabel.text = currentStop?.stopName
                
                restClient.getNextBuses(stopId: (currentStop?.id)!, maxMinutes: NEXT_BUSES_MAX_TIME,
                    onSuccess: { (resultarray) -> Void in
                        var connections = [Connection]()
                        for (_,result) in resultarray {
                            let connection = toConnection(result)
                            connections.append(connection)
                        }
                        
                        if resultarray.isEmpty {
                            // TODO display to user
                        }
                        
                        if pOnSuccess != nil {
                            pOnSuccess!(connections)
                        }
                        
                        self.departureTimesTableView.setConnections(connections)
                    }, onFailure: { (error) -> Void in
                        // TODO Tell user about network problem
                        
                        if pOnFailure != nil {
                            pOnFailure!(error)
                        }
                })
            } else {
                busStopLabel.text = NSLocalizedString(
                    "No bus stops nearby",
                    comment: "Shown if no bus stop could be found")
            }
    }
    
    func refreshConnections(callback: ([Connection] -> Void)) {
        refreshStop(onSuccess: { (connections: [Connection]) -> Void in
            callback(connections)
        })
    }
    
    func startLookingForStopsNearby() {
        startProgress("Looking for bus stops nearby")
        
        LOCATION_MANAGER.delegate = self
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Restricted ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
                LOG.info("User denied permission for location.")
                alerts.displayNoLocation(onRetry: { () -> Void in
                    LOCATION_MANAGER.requestWhenInUseAuthorization()
                })
        } else if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            LOCATION_MANAGER.requestWhenInUseAuthorization()
        } else {
            onLocationAuthorized()
        }
        
    }
    
    func startProgress(text: String) {
        activityIndicator.hidden = false
        activityIndicatorText.text = NSLocalizedString(
            text,
            comment: "Text shown when refreshing status")
        activityIndicatorText.hidden = false
        activityIndicator.startAnimating()
    }
    
    func stopProgress() {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        activityIndicatorText.hidden = true
    }
    
    
}

