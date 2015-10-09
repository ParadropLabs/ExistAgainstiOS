//
//  Views.swift
//  FabAgainst
//
//  Created by Mickey Barboi on 10/9/15.
//  Copyright © 2015 paradrop. All rights reserved.
//
//  This is UI and UX code. It does not rely on any fabric functionality.

import Foundation
import Riffle
import RMSwipeTableViewCell
import M13ProgressSuite


class CardCell: RMSwipeTableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewHolder: UIView!
    
    func resetContentView() {
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.contentView.frame = CGRectOffset(self.contentView.bounds, 0.0, 0.0)
            }) { (b: Bool) -> Void in
                self.shouldAnimateCellReset = true
                self.cleanupBackView()
                self.interruptPanGestureHandler = false
                self.panner.enabled = true
        }
    }
}

class PlayerCell: UICollectionViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelScore: UILabel!
}

class TickingView: M13ProgressViewBar {
    // A simple subclass that ticks down when given a time
    var timer: NSTimer?
    var current: Double = 1.0
    var increment: Double = 0.1
    let tickRate = 0.1
    
    func countdown(time: Double) {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }

        self.primaryColor = UIColor.whiteColor()
        self.secondaryColor = UIColor.blackColor()
        
        increment = tickRate / time
        current = 1.0
        self.setProgress(CGFloat(current), animated: true)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(tickRate, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
    func tick() {
        current -= increment
        
        if current <= 0 {
            timer?.invalidate()
            timer = nil
            current = 1.0
        } else {
            self.setProgress(CGFloat(current), animated: true)
        }
    }
}


//MARK: General Utility
func flashCell(target: Player, model: [Player], collection: UICollectionView) {
    let index = model.indexOf(target)
    let cell = collection.cellForItemAtIndexPath(NSIndexPath(forRow: index!, inSection: 0))
    UIView.animateWithDuration(0.15, animations: { () -> Void in
        cell?.backgroundColor = UIColor.whiteColor()
    }) { (_:Bool) -> Void in
        cell?.backgroundColor = UIColor.blackColor()
    }
}


