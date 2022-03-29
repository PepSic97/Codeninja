//
//  Int+Ex.swift
//  CodeNinja
//
//  Created by Giuseppe Sica on 21/03/22.
//

import Foundation


extension Int{
    static func random(min: Int, max: Int) -> Int {
        assert(min < max)
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }
}
