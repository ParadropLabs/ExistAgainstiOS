//: Playground - noun: a place where people can play

//import Cocoa
import UIKit
import Foundation
import Riffle
import Mantle

// Protcol all expected types must implement
protocol Convertible {
    static func convert(object: AnyObject) -> Convertible?
}

extension Int: Convertible {
    static func convert(object: AnyObject) -> Convertible? {
        if let x = object as? Int {
            return x
        }
        
        if let x = object as? String {
            return Int(x)
        }
        
        return nil
    }
}

extension RiffleModel: Convertible {
    static func convert(object: AnyObject) -> Convertible? {
        if let a = object as? [NSObject: AnyObject] {
            return MTLJSONAdapter.modelOfClass(self, fromJSONDictionary: a) as? Convertible
        }
        
        return nil
    }
}

class Dog: RiffleModel {
    var name: String = "Default"
    
    func woof() -> String {
        return "Hello."
    }
}


////////////////////////////
// Conversion methods
////////////////////////////

func con<A: AnyObject, T: Convertible>(a: A?, _ t: T.Type) -> T? {
    if let x = a {
        return t.convert(x) as? T
    }
    
    return nil
}

func con<A: AnyObject, T: CollectionType where T.Generator.Element: Convertible>(a: A?, _ t: T.Type) -> T? {
    // Attempt to convert an array of arbitrary elements to collection of convertible elements. The sequence is passed
    // as a type of these elements as understood from the method signature where they're declared.
    
    // The expected sequence element type
    // Not implemented: recursive handling of nested data structures
    let convertibleElement = T.Generator.Element.self
    print(convertibleElement)
    
    // Attempt to process the incoming parameters as an array
    if let x = a as? NSArray {
        var ret: [T.Generator.Element] = []
        
        for e in x {
            if let converted = convertibleElement.convert(e) as? T.Generator.Element {
                ret.append(converted)
            } else {
                // If a single one of the casts fail, stop processing the collection.
                // This behavior may not always be expected since it does not allow collections of optionals
                
                // TODO: Print out or return some flavor of log here?
                return nil
            }
        }
        
        return ret as? T
    }
    
    // Can cover arrays here, too
    
    return nil
}

//let oneDogJson: AnyObject = ["name":"Johnson"]
//let oneDog = con(oneDogJson, Dog.self)
//oneDog?.woof()

let dogJson: AnyObject = [["name":"Fido"], ["name":"Spot"]]
let result = con(dogJson, [Dog].self)!
result[0].name

let someStrings: AnyObject = ["1", "2", "3"]
let someInts = con(someStrings, [Int].self)

//let integer = con("1", Int.self)





