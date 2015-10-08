//
//  LoginViewController.swift
//  FabAgainst
//
//  Created by Mickey Barboi on 9/29/15.
//  Copyright © 2015 paradrop. All rights reserved.
//

import UIKit
import Riffle
import IHKeyboardAvoiding

class LoginViewController: UIViewController, RiffleDelegate {
    @IBOutlet weak var textfieldUsername: UITextField!
    var session: RiffleSession?
    
    var timer: NSTimer?
    
    @IBOutlet weak var buttonLogin: UIButton!
    
    
    override func viewDidLoad() {
        setFabric("ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws")
        IHKeyboardAvoiding.setAvoidingView(buttonLogin)
    }
    
    @IBAction func login(sender: AnyObject) {
        if DEB {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("landing") as! LandingViewController
            self.showViewController(controller, sender: self)
            return
        }
        
        let name = textfieldUsername.text!
 
        session = RiffleSession(domain: "pd.demo.cardsagainst." + name)
        session!.delegate = self
        session!.connect()
    }
    
    func onJoin() {
        print("Session connected")
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("landing") as! LandingViewController
        controller.session = session
        self.showViewController(controller, sender: self)
    }
    
    func onLeave() {
        print("Session disconnected")
    }
}
