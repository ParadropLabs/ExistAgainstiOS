//
//  LandingViewController.swift
//  FabAgainst
//
//  Created by Mickey Barboi on 9/29/15.
//  Copyright © 2015 paradrop. All rights reserved.
//

import UIKit
import Riffle

class LandingViewController: UIViewController {
    var session: RiffleSession?
    
    
    @IBAction func play(sender: AnyObject) {
        // Negotiate a room
        session?.call("pd.demo.cardsagainst/getRoom", args: [], handler: { (result: [AnyObject]) -> () in
            print("Call Returned")
        })
        
        // Present the play view controller
    }
}
