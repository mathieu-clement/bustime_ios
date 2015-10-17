//
//  StopPickerViewController.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/16/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import UIKit

class StopPickerViewController: UIViewController {
    
    var stops = [Stop]() {
        didSet {
            stopPickerDelegate.stops = stops
        }
    }
    
    let stopPickerDelegate = StopUIPickerViewDelegate()
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO Do not allow pressing on button if stops is empty
        // TODO Error message if not stop returned
        pickerView.delegate = stopPickerDelegate
        pickerView.dataSource = stopPickerDelegate
        
        let parent = parentViewController as! BTNavigationController
        pickerView.selectRow(stops.indexOf({ (e) -> Bool in
            return e == parent.currentStop!
        })!, inComponent: 0, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        let parent = parentViewController as! BTNavigationController
        parent.currentStop = stops[pickerView.selectedRowInComponent(0)]
    }
    
}
