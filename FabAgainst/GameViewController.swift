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
        labelActiveCard.text = ""
        
        
        if state == .Picking {
            table = hand
        }
        
        // otherwise....
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
    
    override func viewWillDisappear(animated: Bool) {
        // Have to unsub or unregister!
        // TODO: overload for version that doesn't take a handler block
        session!.call(room + "/leave", session!.domain, handler: nil)
    }

    
    // MARK: Incoming state 
    func picking(domain: String, card: [String: AnyObject]) {
        state = .Picking
        labelActiveCard.text = card["text"]! as! String
        chooser = domain
        
        // are we choosing this round?
        print("Choosen domain: \(domain), our domain: \(session!.domain)")
        table = chooser == session!.domain ? [] : hand
        
        tableCard.reloadData()
    }
    
    func choosing(choices: [[String: AnyObject]]) {
        state = .Choosing
        print("Choosing: \(table)")
        table = choices.map { Card(json: $0) }
        tableCard.reloadData()
    }
    
    func scoring(player: String) {
        state = .Scoring
        print("Player \(player) won!")
        if player == "" {
            // chooser didn't pick. No winner
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
    
    
    //MARK: Table Delegate and Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("card") as! CardCell
        cell.labelTitle.text = table[indexPath.row].text
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


