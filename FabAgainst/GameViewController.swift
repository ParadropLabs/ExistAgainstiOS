//
//  GameViewController.swift
//  FabAgainst
//
//  Created by Mickey Barboi on 9/29/15.
//  Copyright © 2015 paradrop. All rights reserved.
//

/*
Musings: 
    Table allows touches and interactivity based on the current chooser and the phase

Collection always shows the players
    The chooser is always highlighted
    The winner blinks when selected
*/


import UIKit
import Riffle
import RMSwipeTableViewCell
import M13ProgressSuite

// Testing ui code
let DEB = true

class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, RMSwipeTableViewCellDelegate {
    
    @IBOutlet weak var viewProgress: M13ProgressViewBar!
    @IBOutlet weak var labelActiveCard: UILabel!
    @IBOutlet weak var tableCard: UITableView!
    @IBOutlet weak var collectionPlayers: UICollectionView!
    
    var session: RiffleSession?
    var state: State = .Empty
    var players: [Player] = []
    var hand: [Card] = []
    var room: String = ""
    
    // The cards currently in play
    var table: [Card] = []
    
    //Questionable or temporary
    var chooser = ""
    
    override func viewDidLoad() {
        tableCard.estimatedRowHeight = 100
        tableCard.rowHeight = UITableViewAutomaticDimension
        
        if DEB {
            state = .Picking
            
            let c = Card()
            c.text = "Test 1"
            c.id = 1
            hand.append(c)
            
            let d = Card()
            d.text = "Test 1Test 1Test 1Test 1Test 1Test 1Test 1Test 1Test 1Test 1Test 1Test 1Test 1Test 1Test 1"
            d.id = 1
            hand.append(d)
        }
        
        if state == .Picking {
            table = hand
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !DEB {
            session!.subscribe(room + "/round/picking", picking)
            session!.subscribe(room + "/round/choosing", choosing)
            session!.subscribe(room + "/round/scoring", scoring)

            //session!.subscribe(room + "/play/picked", picked)
            
            session!.register(session!.domain + "/draw", draw)
            session!.subscribe(room + "/joined", newPlayer)
            session!.subscribe(room + "/left", playerLeft)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Have to unsub or unregister!
        // TODO: overload for version that doesn't take a handler block
        if !DEB {
            session!.call(room + "/leave", session!.domain, handler: nil)
        }
    }

    
    // MARK: Incoming state 
    func picking(domain: String, card: Card) {
        state = .Picking
        labelActiveCard.text = card.text
        chooser = domain
        
        // are we choosing this round?
        print("Choosen domain: \(domain), our domain: \(session!.domain)")
        table = chooser == session!.domain ? [] : hand
        
        tableCard.reloadData()
    }
    
    func choosing(choices: [[String: AnyObject]]) {
        state = .Choosing
        print("Choosing: \(table)")
        table = choices.map { Card.fromJson($0) }
        tableCard.reloadData()
    }
    
    func scoring(player: String) {
        state = .Scoring
        
        if player == "" {
            // chooser didn't pick. No winner. Strictly speaking, this shouldn't be possible
        } else {
            // Flash the winner, remove the other cards off the screen, incrememnt their score on the bottom pane
            print("Player \(player) won!")
            var winners = players.filter { $0.domain == player }
            
            if winners.count == 0 {
                print("Uh oh. Nothing found.")
            } else {
                let winner = winners[0]
                winner.score += 1
            }
            
            // Flash the cell
            
            collectionPlayers.reloadData()
        }
    }
    
    func newPlayer(player: String) {
        let p = Player()
        p.domain = player
        players.append(p)
        collectionPlayers.reloadData()
    }
    
    func playerLeft(player: String) {
        let p = players.filter({$0.domain == player})[0]
        players.removeObject(p)
        collectionPlayers.reloadData()
    }
    
    func picked(player: String) {
        // Show that the player picked. Defer for now
    }
    
    func draw(cardJson: [String: AnyObject]) {
        hand.append(Card.fromJson(cardJson))
    }
    
    
    //MARK: Table Delegate and Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("card") as! CardCell
        cell.labelTitle.text = table[indexPath.row].text
        
        // Style the cell
        cell.labelTitle.layer.cornerRadius = 6
        cell.labelTitle.layer.masksToBounds = true
        
        let backView = UIView(frame: cell.frame)
        backView.backgroundColor = UIColor.clearColor()
        cell.backgroundView = backView
        
        cell.backgroundColor = UIColor.clearColor()
        cell.backViewbackgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return table.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let ourChoice = chooser == session!.domain
        
        // Dont really have to worry about out of turn selections-- the chooser should see a blank table 
        // based on the construction of the table in the reload methods
        if state == .Picking && !ourChoice {
            session!.call(room + "/play/pick", session!.domain, table[indexPath.row].id, handler: nil )
        } else if state == .Choosing && ourChoice {
            session!.publish(room + "/play/choose", table[indexPath.row].id)
            //TOOD: remove the card from the table and reload
        } else {
            print("Pick occured outside a valid round! OurChoice: \(ourChoice), state: \(state)")
        }
    }
    
    
    //MARK: Collection Delegate and Data Source
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("player", forIndexPath: indexPath) as! PlayerCell
        let player = players[indexPath.row]
        
        cell.labelName.text = player.domain.stringByReplacingOccurrencesOfString("pd.demo.cardsagainst.", withString: "")
        cell.labelScore.text = "\(player.score)"
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2, height: 100)
    }
    
    
    //MARK: Switping Delegate
    func swipeTableViewCell(swipeTableViewCell: RMSwipeTableViewCell!, didSwipeToPoint point: CGPoint, velocity: CGPoint) {
        let cell = swipeTableViewCell as! CardCell
        
        let MAX = CGFloat(70.0)
        
        // right side selection
        if point.x >= MAX {
//            cell.resetCellFromPoint(point, velocity:
            cell.resetContentView()
            cell.interruptPanGestureHandler = true
        }
        
        // Left side selection
        if point.x <= (-1 * MAX) {
            
        }
        

    }
    
    // MARK: Actions
    @IBAction func leave(sender: AnyObject) {
        // Called when the user wants to leave the room. Unregister/subscribe to all relevant bits
        
        if !DEB {
            session!.unsubscribe(room + "/round/picking")
            session!.unsubscribe(room + "/round/choosing")
            session!.unsubscribe(room + "/round/scoring")
            
            //session!.unsubscribe(room + "/play/picked")
            
            session!.unregister(session!.domain + "/draw")
            session!.unsubscribe(room + "/joined")
            session!.unsubscribe(room + "/left")
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: Timer Functions
    func tick() {
        //timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
        // Set primaryColor and secondaryColor for the other effects
        // Temp
        var timer: NSTimer?
        var progress = 0.0
        
        progress += 0.1
        viewProgress.setProgress(CGFloat(progress), animated: true)
    }
}


class CardCell: RMSwipeTableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    
    func resetContentView() {
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.contentView.frame = CGRectOffset(self.contentView.bounds, 0.0, 0.0)
        }) { (b: Bool) -> Void in
            self.shouldAnimateCellReset = true
            self.cleanupBackView()
            self.interruptPanGestureHandler = false
        }
    }
}

class PlayerCell: UICollectionViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelScore: UILabel!
}

