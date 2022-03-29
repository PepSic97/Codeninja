//
//  CGFloat+Ext.swift
//  CodeNinja
//
//  Created by Giuseppe Sica on 21/03/22.
//

import CoreGraphics

extension CGFloat{
    static func random()-> CGFloat{
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat{
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
    
}
