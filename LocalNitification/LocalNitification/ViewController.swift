//
//  ViewController.swift
//  LocalNitification
//
//  Created by 吳政緯 on 2017/6/24.
//  Copyright © 2017年 吳政緯. All rights reserved.
//

import UIKit
import UserNotifications
class ViewController: UIViewController {
    
    @IBAction func action(_ sender: Any)
    {
        //推播內容
        let content = UNMutableNotificationContent()
        content.title = "How many days are there in one year"
        content.subtitle = "Do you know?"
        content.body = "Do you really know?"
        content.badge = 1
        
        //何時推播
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
       
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound,.badge] ) {didAllow, error in
            print(didAllow,error)
        }
    }
    
    
    
    
}


