//
//  Utils.swift
//  FabAgainst
//
//  Created by Mickey Barboi on 9/29/15.
//  Copyright © 2015 paradrop. All rights reserved.
//

import Foundation
import UIKit

func pushController(sender: UIViewController, identifier: String, data: [String: AnyObject]?) {
    // Presents a controller, passing it the given data using KVO
    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(identifier)
    
    if let d = data {
        for (k, v) in d {
            controller.setValue(v, forKey: k)
        }
    }
    
    sender.navigationController?.pushViewController(controller, animated: true)
}