//
//  StopUIPickerViewDelegate.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/16/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import UIKit

public class StopUIPickerViewDelegate : NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    public var stops = [Stop]()
    
    @objc public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let stop = stops[row]
        if stop.platformCode != nil {
            return "\(stop.stopName) (Pl. \(stop.platformCode!))"
        } else {
            return stop.stopName
        }
    }
    
    @objc public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @objc public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stops.count
    }

}