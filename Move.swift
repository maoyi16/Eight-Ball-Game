//
//  Move.swift
//  Eight Ball Pool Game
//
//  Created by 毛易 on 2/19/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import GameplayKit

class Move: NSObject, GKGameModelUpdate {
    
    var value: Int = 0
    let impluse:CGVector
    
    init(impluse: CGVector) {
        self.impluse = impluse
    }
}
