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
    
    var cardsQuestion13: [[String: AnyObject]] = []
    var cardsAnswer13: [[String: AnyObject]] = []
    var cardsQuestion21: [[String: AnyObject]] = []
    var cardsAnswer21: [[String: AnyObject]] = []
    
    
    override func viewDidLoad() {
        // Load cards
        cardsQuestion13 = loadCards("q13")
        cardsAnswer13 = loadCards("a13")
        cardsQuestion21 = loadCards("q21")
        cardsAnswer21 = loadCards("a21")
    }
    
    @IBAction func play(sender: AnyObject) {
        // Ask for a room and present the gameplay controller
        session?.call("pd.demo.cardsagainst/getRoom", args: [], handler: { (result: [AnyObject]) -> () in
            // Expecting list of players and cards
            print(result)
            pushController(self, identifier: "game", data: ["session": self.session!])
        })
    }
}

func loadCards(name: String) -> [[String: AnyObject]] {
    let jsonPath = NSBundle.mainBundle().pathForResource(name, ofType: "json")
    return try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: jsonPath!)!, options: NSJSONReadingOptions.AllowFragments) as! [[String: AnyObject]]
}

