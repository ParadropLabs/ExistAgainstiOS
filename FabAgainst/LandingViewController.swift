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
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func play(sender: AnyObject) {
        // Ask for a room and present the gameplay controller
        session?.call("pd.demo.cardsagainst/getRoom", args: [], handler: { (result: [AnyObject]) -> () in
            pushController(self, identifier: "game", data: ["session": self.session!])
        })
    }
}

