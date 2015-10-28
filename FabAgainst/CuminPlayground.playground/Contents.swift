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
    
    // Can cover dicts here, too
    
    return nil
}


//let oneDogJson: AnyObject = ["name":"Johnson"]
//let oneDog = con(oneDogJson, Dog.self)
//oneDog?.woof()

//let dogJson: AnyObject = [["name":"Fido"], ["name":"Spot"]]
//let result = con(dogJson, [Dog].self)!
//result[0].name

let someStrings: AnyObject = ["1", "2", "3"]
let someInts = con(someStrings, [Int].self)

let integer = con("1", Int.self)



class Carrier<T> {
    var type: Convertible.Type
    
    var handler: (AnyObject) -> T? = { (a: AnyObject) -> T? in
        return nil
    }
    
    init<T: CollectionType where T.Generator.Element: Convertible>(t: T.Type) {
        type = T.Generator.Element.self
        handler = self.sequence
        
        let someArray: [T.Generator.Element] = []
        print(someArray)
    }
    
    init<T: Convertible>(t: T.Type) {
        type = t
        handler = self.single
    }
    
    init<T: Any>(t: T.Type) {
        print("AnyTriggered")
        type = Int.self
    }
    
    func single<A: AnyObject>(a: A?) -> T? {
        if let x = a {
            return type.convert(x) as? T
        }

        return nil
    }
    
    func convert(object: AnyObject) -> T? {
        return handler(object)
    }
    
    func sequence<A: AnyObject>(a: A) -> T? {
        if let x = a as? NSArray {
            var ret: [Convertible] = []

            for e in x {
                let z = type.convert(e)
                ret.append(z!)
            }
            
            print(T.self)
            let z = unsafeBitCast(ret, T.self)
            return z
        }
        
        return nil
    }
    
    class func staticConvert<A: AnyObject, T: Convertible>(a: A?, _ t: T.Type) -> T? {
        if let x = a {
            return t.convert(x) as? T
        }
        
        return nil
    }
    
//    class func staticConvert<A: AnyObject, T: CollectionType where T.Generator.Element: Convertible>(a: A?, _ t: T.Type) -> T? {
//        // Attempt to convert an array of arbitrary elements to collection of convertible elements. The sequence is passed
//        // as a type of these elements as understood from the method signature where they're declared.
//        
//        // The expected sequence element type
//        // Not implemented: recursive handling of nested data structures
//        let convertibleElement = T.Generator.Element.self
//        
//        // Attempt to process the incoming parameters as an array
//        if let x = a as? NSArray {
//            var ret: [T.Generator.Element] = []
//            
//            for e in x {
//                if let converted = convertibleElement.convert(e) as? T.Generator.Element {
//                    ret.append(converted)
//                } else {
//                    // If a single one of the casts fail, stop processing the collection.
//                    // This behavior may not always be expected since it does not allow collections of optionals
//                    
//                    // TODO: Print out or return some flavor of log here?
//                    return nil
//                }
//            }
//            
//            return ret as? T
//        }
//        
//        // Can cover dicts here, too
//        
//        return nil
//    }
}

//let converter = Carrier<Int>(t: Int.self)
//converter.convert("1")
//
//
//let collectionConverter = Carrier<[Int]>(t: [Int].self)
//collectionConverter.convert(["1"])

func add(a: Int) {
    print(a)
}

func cuin<A>(fn: (A) -> ()) -> ([AnyObject]) -> () {
    //return { (a: [AnyObject]) in fn(con(a[0], A.self)!) }
    //return { (a: [AnyObject]) in fn(Carrier<A>(t: A.self).convert(a[0])!) }
    //return { (a: [AnyObject]) in fn(Carrier.staticConvert(a[0], A.self)!) }
    
    // This works, but moves the issue to runtime
    return { (a: [AnyObject]) in
        print("Inside dead method")
        let a = Carrier<A>(t: A.self).convert(a[0])
    }
}

let cuminized = cuin(add)
print(cuminized(["2"]))


