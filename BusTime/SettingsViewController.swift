//
//  SettingsViewController.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/17/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController {
    
    
    @IBOutlet weak var maxRadiusSlider: UISlider!
    
    @IBOutlet weak var maxRadiusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let maxRadius = NSUserDefaults.standardUserDefaults().integerForKey("maxRadius")
        maxRadiusSlider.value = Float(maxRadius)
        refreshLabelForDistance(maxRadius)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let intValue = Int(sender.value)
        
        if sender === maxRadiusSlider {
            refreshLabelForDistance(intValue)
            NSUserDefaults.standardUserDefaults().setInteger(intValue, forKey: "maxRadius")
        }
    }
    
    private func refreshLabelForDistance(distance: Int) {
        maxRadiusLabel.text = "\(distance) m"
    }
    
}