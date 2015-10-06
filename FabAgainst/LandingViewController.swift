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
        // Ask for a room and present the gameplay controller
        
        session?.call("pd.demo.cardsagainst/play", session!.domain) { (result: [AnyObject]) -> () in
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("game") as! GameViewController
            
            // Annoying. There should be a way to convert the responses as needed-- casting responses
            let json = result[0] as! [String: AnyObject]
            let rawPlayers = json["players"] as! [[String: AnyObject]]
            let rawCards = json["hand"] as! [[String: AnyObject]]
            
            controller.hand = rawCards.map { Card(json: $0) }
            controller.players = rawPlayers.map { Player(json: $0) }
            controller.state = State(json["state"] as! String)!
            controller.room = json["room"] as! String
            controller.session = self.session!

            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}