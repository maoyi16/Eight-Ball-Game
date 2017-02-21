//
//  Pocket.swift
//  Eight Ball Pool Game
//
//  Created by 毛易 on 1/24/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import Foundation
import SpriteKit

class Pocket:NSCopying {
    
    let posX:CGFloat
    let posY:CGFloat
    let radius: CGFloat = GameConstants.PocketRadius
    init(x:CGFloat, y:CGFloat) {
        posX = x
        posY = y
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Pocket(x: self.posX, y: self.posY)
    }
}
