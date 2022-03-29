//
//  EnumType.swift
//  CodeNinja
//
//  Created by Giuseppe Sica on 22/03/22.
//

import Foundation

enum SequenceType: Int {
    case OneNoBomb, One, TwoWithOneBomb, Two, Three, Four, Five, Six
}

enum ForceBomb{
    case Never, Always, Defaults
}

enum SpawnType {
    case None, SpawnOne, SpawnTwo, SpawnThree, SpawnBonus, SpawnIcon
}
