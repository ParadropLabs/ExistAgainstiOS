//
//  Shared.swift
//  FabAgainstBackend
//
//  Created by Mickey Barboi on 10/1/15.
//  Copyright © 2015 paradrop. All rights reserved.

// This code is shared across the app and the container.

import Foundation
import Riffle

// Representation of a player in the game
class Player: RiffleModel {
    var id = Int(arc4random_uniform(UInt32.max))
    var domain = ""
    var score = 0
    
    var demo = false
    var chooser = false
    var hand: [Card] = []
    var pick: Card?
    
    func toJson() -> [String: AnyObject] {
        // leftover from the old code
        let picked = pick == nil ? -1 : pick!.id
        
        return [
            "domain": domain,
            "score": score,
            "pick": picked
        ]
    }
    
    class func fromJson(json: [String: AnyObject]) -> Player {
        let player = Player()
        player.domain = json["domain"] as! String
        player.score = json["score"] as! Int
        return player
    }
}

class Card: RiffleModel {
    var id = -1
    var text = ""
    
    class func fromJson(json: [String: AnyObject]) -> Card {
        let card = Card()
        card.id = json["id"] as! Int
        card.text = json["text"] as! String
        return card
    }
    
    func json() -> [String: AnyObject] {
        return [
            "id": id,
            "text": text
        ]
    }
}

func ==(lhs: Card, rhs: Card) -> Bool {
    return lhs.id == rhs.id
}

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.domain == rhs.domain
}


class Deck {
    var questions: [Card] = []
    var answers: [Card] = []
    
    init(questionPath: String, answerPath: String) {
        //Takes the paths of the JSON source files, creates cards
        
        let load = { (name: String) -> [Card] in
            let jsonPath = NSBundle.mainBundle().pathForResource(name, ofType: "json")
            let x = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: jsonPath!)!, options: NSJSONReadingOptions.AllowFragments) as! [[String: AnyObject]]
            return x.map { Card.fromJson($0) }
        }
        
        questions = load(questionPath)
        answers = load(answerPath)
    }
    
    func drawCards(var cards: [Card], number: Int) -> [Card] {
        // draws a number of cards for the player. Tracks duplicates (?)
        var ret: [Card] = []
        
        for _ in 0...number {
            ret.append(randomElement(&cards, remove: true))
        }
        
        return ret
    }
    
    func reshuffleCards(inout target: [Card], cards: [Card]) {
        // "Realease" the cards formerly in play by shuffling them back into the deck
        target.appendContentsOf(cards)
    }
}

func getPlayer(players: [Player], domain: String) -> Player {
    return players.filter({$0.domain == domain})[0]
}

enum State {
    case Empty, Picking, Choosing, Scoring
    
    init?(_ raw: String) {
        switch raw {
        case "Empty": self = .Empty;
        case "Picking": self = .Picking;
        case "Choosing": self = .Choosing;
        case "Scoring": self = .Scoring;
        default: return  nil
        }
    }
    
    var description : String {
        switch self {
        case .Empty: return "Empty";
        case .Picking: return "Picking";
        case .Choosing: return "Choosing";
        case .Scoring: return "Scoring";
        }
    }
}

// Utility function to generate random strings
func randomStringWithLength (len : Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i=0; i < len; i++){
        let rand = arc4random_uniform(UInt32(letters.length))
        randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return String(randomString)
}

func randomElement<T>(inout arr: [T], remove: Bool = false) -> T {
    let i = Int(arc4random_uniform(UInt32(arr.count)))
    let o = arr[i]
    
    if remove {
        arr.removeAtIndex(i)
    }
    
    return o
}

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

