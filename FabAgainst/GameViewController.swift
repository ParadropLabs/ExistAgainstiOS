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

class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
    
    
    override func viewWillAppear(animated: Bool) {
        // Animations?
//        establish()
        labelActiveCard.text = ""
        
        // HAVE TO UNSUB
    }
    
    override func viewDidAppear(animated: Bool) {
        session!.subscribe(room + "/round/picking", picking)
        session!.subscribe(room + "/round/choosing", choosing)
        session!.subscribe(room + "/round/scoring", scoring)

        //session!.subscribe(room + "/play/picked", picked)
        
        session!.register(session!.domain + "/draw", draw)
        session!.subscribe(room + "/joined", newPlayer)
        session!.subscribe(room + "/left", playerLeft)
    }

    
    // MARK: Incoming state 
    func picking(domain: String, card: [String: AnyObject]) {
        labelActiveCard.text = card["text"]! as! String
        chooser = domain
        tableCard.reloadData()
    }
    
    func choosing(table: [String: AnyObject]) {
        // dict of players and their card choices
    }
    
    func scoring(player: String) {
        if player == "" {
            // chooser didn't pick. No winner
            // TODO: choose automatically?
        } else {
            // Flash the winner, remove the other cards off the screen, incrememnt their score on the bottom pane
        }
    }
    
    func newPlayer(player: String) {
        players.append(Player(domain: player))
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
        hand.append(Card(json: cardJson))
    }
    
    func leave() {
        // Have to unsub or unregister!
        // TODO: overload for version that doesn't take a handler block
        session!.call(room + "/leave", session!.domain, handler: nil)
    }
    
    
    //MARK: Table Delegate and Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("card") as! CardCell
        cell.labelTitle.text = hand[indexPath.row].text
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chooser == session!.domain {
            // TODO: show the active list of picked cards (flipped over or not)
            return hand.count
        } else {
            return hand.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // NOTE: if choosing, the non-choosing players should see a list of the submissions
        
        // We choose this round
        if chooser == session!.domain {
            session!.publish(room + "/play/choose", table[indexPath.row].id)
        } else {
            session!.publish(room + "/play/pick", hand[indexPath.row].id)
        }
        
        // TODO: remove the remaining cards and block future picks or chooses
    }
    
    
    //MARK: Collection Delegate and Data Source
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("player", forIndexPath: indexPath) as! PlayerCell
        let name = players[indexPath.row].domain
        cell.labelName.text = name.stringByReplacingOccurrencesOfString("pd.demo.cardsagainst.", withString: "")
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2, height: 100)
    }
}


class CardCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
}

class PlayerCell: UICollectionViewCell {
    @IBOutlet weak var labelName: UILabel!
}


/* Perhaps Uneeded
func establish() {
// Rebuilds the UI to match the current state.
// Do we need this?

switch state {
case .Picking:
break
case .Choosing:
break
case .Scoring:
break
case .Empty:
print("Empty room. Cant do anything")
}
}
*/


