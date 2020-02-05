//
//  Helpers.swift
//  Tracery
//
//  Created by Benzi on 11/03/17.
//  Copyright © 2017 Benzi Ahamed. All rights reserved.
//

import Foundation
import XCTest

func XCTAssertItemInArray<T: Comparable>(item: T, array: [T]) {
    XCTAssert(array.contains(item), "\(item) was not found in \(array)")
}

extension Array {
    
    func regexGenerateMatchesAnyItemPattern() -> String {
        return "(" + self.map { "\($0)" }.joined(separator: "|") + ")"
    }
    
}

extension Sequence {
    
    func mapDict<Key: Hashable,Value>(_ transform:(Iterator.Element)->(Key, Value)) -> Dictionary<Key, Value> {
        var d = Dictionary<Key, Value>()
        forEach {
            let (k,v) = transform($0)
            d[k] = v
        }
        return d
    }
    
    @discardableResult
    func scan<T>(_ initial: T, _ combine: (T, Iterator.Element) throws -> T) rethrows -> [T] {
        var accu = initial
        return try map { e in
            accu = try combine(accu, e)
            return accu
        }
    }
}



//func dump<T>(_ item: T) {
//    if let debuggable = item as? CustomDebugStringConvertible {
//        print(debuggable.debugDescription)
//    }
//    print(item)
//}
