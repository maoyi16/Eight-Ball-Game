//
//  Ball.swift
//  Eight Ball Pool Game
//
//  Created by 毛易 on 1/23/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

enum BallColor {
    case Blue
    case Red
    case Black
    case White
    case None
}

let colorDict:[BallColor: UIColor] = [
    .Blue: UIColor.blue,
    .Red: UIColor.red,
    .Black: UIColor.black,
    .White: UIColor.white,
    .None: UIColor.clear
]

protocol Ball:NSCopying {
    
    init(posX: CGFloat, posY: CGFloat, color: BallColor)
    
    func update(deltaTime seconds: TimeInterval)
    
    var velocity:CGVector {get}
    
    var color: BallColor {get}
    
    var position:CGPoint! {get set}
    
    var isStable:Bool {get}
    
    var node:SKShapeNode! {get}
    
    var isNormalBall:Bool {get}
    
    static var radius:CGFloat {get}
}
