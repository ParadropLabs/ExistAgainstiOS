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
import IHKeyboardAvoiding

class LandingViewController: UIViewController, RiffleDelegate {
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var viewLogo: SpringView!
    @IBOutlet weak var viewButtons: SpringView!
    @IBOutlet weak var viewLogin: SpringView!
    
    @IBOutlet weak var textfieldUsername: UITextField!
    
    var session: RiffleSession?
    
    
    override func viewDidLoad() {
        setFabric("ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws")
        IHKeyboardAvoiding.setAvoidingView(viewLogin)
    }
    
    override func viewWillAppear(animated: Bool) {
        textfieldUsername.layer.borderColor = UIColor.whiteColor().CGColor
        textfieldUsername.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
   
    override func viewDidAppear(animated: Bool) {
        viewLogo.animate()
        viewLogin.animate()
    }

    
    // MARK: Core Logic
    func play() {
        if DEB {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("game") as! GameViewController
            self.modalPresentationStyle = .CurrentContext
            
            let effect = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
            effect.frame = controller.view.frame
            controller.view.insertSubview(effect, atIndex:0)
            controller.modalPresentationStyle = .OverFullScreen
            
            self.presentViewController(controller, animated: true, completion: nil)
            return
        }
        
        // Ask for a room and present the gameplay controller
        // This is going to stick around for a bit until the "call" methods are updated to use cumin.
        session?.call("pd.demo.cardsagainst/play", session!.domain) { (result: [AnyObject]) -> () in
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("game") as! GameViewController
            
            let json = result[0] as! [String: AnyObject]
            let rawPlayers = json["players"] as! [[String: AnyObject]]
            let rawCards = json["hand"] as! [[String: AnyObject]]
            
            controller.currentPlayer.hand = rawCards.map { Card.fromJson($0) }
            controller.players = rawPlayers.map { Player.fromJson($0) }
            controller.state = State(json["state"] as! String)!
            controller.room = json["room"] as! String
            controller.session = self.session!

            let effect = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
            effect.frame = controller.view.frame
            controller.view.insertSubview(effect, atIndex:0)
            controller.modalPresentationStyle = .OverFullScreen
            self.modalPresentationStyle = .CurrentContext
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Riffle Delegate
    func onJoin() {
        print("Session connected")
        
        // Animations
        viewLogin.animation = "zoomOut"
        viewLogin.animate()
        viewButtons.animation = "zoomIn"
        viewButtons.animate()
    }
    
    func onLeave() {
        print("Session disconnected")
    }
    
    
    // MARK: Actions
    @IBAction func login(sender: AnyObject) {
        textfieldUsername.resignFirstResponder()
        let name = textfieldUsername.text!
        
        session = RiffleSession(domain: "pd.demo.cardsagainst." + name)
        session!.delegate = self
        session!.connect()
    }
    
    @IBAction func playpg13(sender: AnyObject) {
        play()
    }
    
    @IBAction func playR(sender: AnyObject) {
        play()
    }
    
}