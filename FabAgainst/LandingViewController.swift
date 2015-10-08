//
//  LandingViewController.swift
//  FabAgainst
//
//  Created by Mickey Barboi on 9/29/15.
//  Copyright © 2015 paradrop. All rights reserved.
//

import UIKit
import Riffle
import Spring

class LandingViewController: UIViewController {
    var session: RiffleSession?
    

    
    
    override func viewDidAppear(animated: Bool) {
//        viewLabel.animation = "zoomIn"
//        viewLabel.layer.animate()
    }

    @IBAction func play(sender: AnyObject) {
        if DEB {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("game") as! GameViewController
            self.modalPresentationStyle = .CurrentContext
            
            let effect = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
            effect.frame = controller.view.frame
            controller.view.insertSubview(effect, atIndex:0)
            controller.modalPresentationStyle = .OverFullScreen
            
            self.presentViewController(controller, animated: true, completion: nil)
//            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
        
        // Ask for a room and present the gameplay controller
        session?.call("pd.demo.cardsagainst/play", session!.domain) { (result: [AnyObject]) -> () in
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("game") as! GameViewController
            
            // Annoying. There should be a way to convert the responses as needed-- casting responses
            let json = result[0] as! [String: AnyObject]
            let rawPlayers = json["players"] as! [[String: AnyObject]]
            let rawCards = json["hand"] as! [[String: AnyObject]]
            
            controller.hand = rawCards.map { Card.fromJson($0) }
            controller.players = rawPlayers.map { Player.fromJson($0) }
            controller.state = State(json["state"] as! String)!
            controller.room = json["room"] as! String
            controller.session = self.session!

            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

/*
UIViewController * contributeViewController = [[UIViewController alloc] init];
UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
UIVisualEffectView *beView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
beView.frame = self.view.bounds;

contributeViewController.view.frame = self.view.bounds;
contributeViewController.view.backgroundColor = [UIColor clearColor];
[contributeViewController.view insertSubview:beView atIndex:0];
contributeViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

[self presentViewController:contributeViewController animated:YES completion:nil];
*/