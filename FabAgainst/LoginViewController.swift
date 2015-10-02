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
    
    @IBOutlet weak var buttonLogin: UIButton!
    
    override func viewDidLoad() {
        setFabric("ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws")
        IHKeyboardAvoiding.setAvoidingView(buttonLogin)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardUp:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDown:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardUp(notification: NSNotification) {
        
    }
    
    func keyboardDown(notification: NSNotification) {
        
    }
    
    @IBAction func login(sender: AnyObject) {
        let name = textfieldUsername.text!
 
        session = RiffleSession(domain: "pd.demo.cardsagainst." + name)
        session!.delegate = self
        session!.connect()
    }
    
    func onJoin() {
        print("Session connected")
        
        // For now assume connection means name was open
        // Present the landing controller
        pushController(self, identifier: "landing", data: ["session": session!])
    }
    
    func onLeave() {
        print("Session disconnected")
    }
}
