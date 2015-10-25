//
//  DepartureTimesScrollViewController.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/17/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import UIKit

/* 
 * When connections become obsolete,
 * the delegate is asked for new data.
 * Because it's asynchronous (network operations and such), it calls the callback
 * when done.
 */
protocol ConnectionsDelegate {
    func refreshConnections(callback: ([Connection] -> Void))
}

class DepartureTimesTableView : UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var connectionsDelegate : ConnectionsDelegate!
    var connections = [Connection]()
    var connectionsByTripShortName = OrderedDictionary<String, [Connection]>()
    let dateFormatter = NSDateFormatter()
    var timer : NSTimer! = nil
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        initTV()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTV()
    }
    
    private func initTV() {
        self.delegate = self
        self.dataSource = self
        self.dateFormatter.locale = NSLocale(localeIdentifier: "fr_CH")
        startRefreshingEveryMinute()
    }
    
    func setConnections(connections: [Connection]) {
        self.connections = connections
        self.connectionsByTripShortName = Connection.groupByTripShortName(connections)
        reloadData()
    }
    
    func startRefreshingEveryMinute() {
        timer = NSTimer.scheduledTimerWithTimeInterval(60,
            target: self,
            selector: Selector("oneMinutePassed"),
            userInfo: nil,
            repeats: true)
    }
    
    func stopRefreshingEveryMinute() {
        if timer != nil {
            timer.invalidate()
        }
    }
    
    func oneMinutePassed() {
        reloadConnections()
    }
    
    private func reloadConnections() {
        // Find if some connections are obsolete
        var hasObsoleteConnections = false
        for connection in connections {
            if minutesFromNow(connection.departure) < 0 {
                hasObsoleteConnections = true
                break
            }
        }
        
        if hasObsoleteConnections {
            // Update from network
            connectionsDelegate.refreshConnections(setConnections)
        } else {
            // Only refresh times
            reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection(section)
    }
    
    override func numberOfRowsInSection(section: Int) -> Int {
        let tripName = connectionsByTripShortName.keys[section]
        return (connectionsByTripShortName[tripName]?.count)!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let lineNo = connectionsByTripShortName.keys[section]
        return String.localizedStringWithFormat(NSLocalizedString(
            "Line $@",
            comment: "Header displaying bus line number"),
            lineNo)
    }
    
    
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
    }
    */
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellForRowAtIndexPath(indexPath)!
    }
    
    override func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        var cell = dequeueReusableCellWithIdentifier("departureTimeTableCell") as UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: "departureTimeTableCell")
        }
        
        let tripIndex = indexPath.section
        let tripShortName = connectionsByTripShortName.keys[tripIndex]
        let connectionIndex = indexPath.row
        let connectionsForTrip = connectionsByTripShortName[tripShortName]
        let connection = connectionsForTrip![connectionIndex]
        let nbMin = minutesFromNow(connection.departure)
        
        cell?.textLabel!.text = connection.tripHeadSign
        if nbMin < 61 {
            cell?.detailTextLabel!.text = "\(nbMin) min"
        } else {
            let isToday = NSCalendar.currentCalendar().compareDate(
                NSDate(),
                toDate: connection.departure,
                toUnitGranularity: NSCalendarUnit.Day).rawValue == 0
            
            if isToday {
                dateFormatter.dateFormat = "HH:mm"
            } else {
                dateFormatter.dateFormat = "dd.MM.yyyy  HH:mm"
            }
            cell?.detailTextLabel!.text = dateFormatter.stringFromDate(connection.departure)
        }
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return connectionsByTripShortName.keys.count
    }
    
}