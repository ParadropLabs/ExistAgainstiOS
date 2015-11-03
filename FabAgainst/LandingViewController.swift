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
        session?.call("pd.demo.cardsagainst/play", session!.domain, handler: { (cards: [Card], players: [Player], state: String, roomName: String) in
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("game") as! GameViewController
            
            // Temporary
            if roomName == "0" {
                return
            }
            
            // Extract us as the current player 
            controller.currentPlayer = players.filter { $0.domain == self.session!.domain }[0]
            controller.currentPlayer.hand = cards
            
            controller.players = players
            controller.state = state
            controller.room = roomName
            controller.session = self.session!
            
            let effect = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
            effect.frame = controller.view.frame
            controller.view.insertSubview(effect, atIndex:0)
            controller.modalPresentationStyle = .OverFullScreen
            self.modalPresentationStyle = .CurrentContext
            
            self.presentViewController(controller, animated: true, completion: nil)
        })
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