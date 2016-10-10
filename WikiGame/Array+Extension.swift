//
//  Array+Extension.swift
//  WikiGame
//
//  Created by Harish Gonnabhaktula on 10/10/16.
//  Copyright © 2016 Harish Gonnabattula. All rights reserved.
//

import Foundation


extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sortInPlace { (_,_) in arc4random() < arc4random() }
        }
    }
}