//: Playground - noun: a place where people can play

//import Cocoa
import Foundation
import Riffle
import Mantle

// Hack to get the arrays to detect
protocol ArrayProtocol{}
extension Array: ArrayProtocol {}

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

func con<A: AnyObject, T: CollectionType where T.Generator.Element: Convertible>(a: A, _ t: T.Type) -> T? {
//    print(T.Generator.Element.self)
//
//    let klass = T.Generator.Element.self
//
//    if klass.canConvert(a) {
//        print("can convert")
//    } else {
//        print("cannot convert")
//    }

    return nil
}

//let oneDogJson: AnyObject = ["name":"Johnson"]
//let oneDog = con(oneDogJson, Dog.self)
//oneDog?.woof()

//let dogJson: AnyObject = [["name":"Fido"], ["name":"Spot"]]
//let result = convert(dogJson, [Dog].self)

let someStrings: AnyObject = ["1", "2", "3"]
let someInts = con(someStrings, [Int].self)

//let integer = con("1", Int.self)

/*
//: Playground - noun: a place where people can play

import Cocoa
import Foundation

// Hack to get the arrays to detect
protocol ArrayProtocol{}
extension Array: ArrayProtocol {}

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

class RiffleModel: NSObject, Convertible {
required override init() {}

static func convert(object: AnyObject) -> Convertible? {
return nil
}
}

class Dog: RiffleModel {
var name: String = "Default"

func woof() -> String {
return "Hello."
}
}

let a = "1"
let b = Int(a)

//extension Array where Element : Convertible, Convertible {
//    static func convert() -> Int {
//        return 1
//    }
//
//    static func canConvert() -> Bool {
//        return true
//    }
//}

//func convert <A, T: Convertible>(a:A?, _ t:T.Type) -> T? {
//    let a = t.canConvert()
//
//    if let y = t as? Array<Convertible>.Type {
//        print("Cast Works")
//    }
//
//    // Works when detecting an array
//    if t is ArrayProtocol.Type {
//        print("Protocol Type")
////        return arrayConverter(a, t: t as! [AnyObject])
//    }
//
//    // Attempt a model conversion
//    if let Klass = t as? RiffleModel.Type {
//        let ret = Klass.init()
//
//        // Make sure the argument is a dictionary
//        ret.deserialize(a as! [String:AnyObject])
//        return ret as! T
//    }
//
//    // Fallthrough so the playground complies
////    let dogs = [Dog(), Dog()]
////    return dogs as! T
//
//    return nil
//}


func add(a: [Int]) {
return
}


func convert<A: AnyObject, T: Convertible>(a: A?, _ t: T.Type) -> T? {
if let x = a {
return t.convert(x) as? T
}

return nil
}

func convert<A: AnyObject, T: CollectionType where T.Generator.Element: Convertible>(a: A?, _ t: T.Type) -> T? {
let convertibleElement = T.Generator.Element.self

// Attempt to process the incoming parameters as an array
if let x = a as? NSArray {
//        let ret = x.map { convertibleElement.convert($0)! }
let ret = []

for e in x {
let con = convertibleElement.convert(e)

if let answer =
print(con)
}

print(ret.dynamicType)
return ret as? T
}

return nil
}


let dogJson: AnyObject = [["name":"Fido"], ["name":"Spot"]]

//let result = convert(dogJson, [Dog].self)
//let lawd = collectionConvert(dogJson, t: [Dog].self)
//let whypleasewhy = convert("1", Int.self)

let integer = convert("1", Int.self)

let someStrings: AnyObject = ["1"]
let someInts = convert(someStrings, [Int].self)






*/


