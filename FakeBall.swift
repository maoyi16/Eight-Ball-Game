//
//  FakeBall.swift
//  Eight Ball Pool Game
//
//  Created by 毛易 on 2/20/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class FakeBall: Ball {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return FakeBall(posX: node.position.x, posY: node.position.y, color: color, withNode: false)
    }
    
    var description: String {
        return "{Color:\(color), Position: \(node.position)}"
    }
    var node: SKShapeNode! = nil
    let color: BallColor
    static let radius: CGFloat = GameConstants.BallRadius
    
    required init(posX: CGFloat, posY: CGFloat, color: BallColor) {
        self.color = color
        defer {
            position = CGPoint(x: posX, y: posY)
        }
        // Test
        node = SKShapeNode(circleOfRadius: GameConstants.BallRadius)
        node.zPosition = 1
        node.fillColor = colorDict[color]!
    }
    
    init(posX: CGFloat, posY: CGFloat, color: BallColor, withNode: Bool) {
        self.color = color
        
        // Test
        if withNode {
            defer {
                position = CGPoint(x: posX, y: posY)
            }
            node = SKShapeNode(circleOfRadius: GameConstants.BallRadius)
            node.zPosition = 1
            node.fillColor = colorDict[color]!
        } else {
            p = CGPoint(x: posX, y: posY)
        }
    }
    
    func update(deltaTime seconds: TimeInterval) {
        guard velocity.dx != 0 || velocity.dy != 0 else {
            return
        }
        let unitNegatedVelocity = negatedVector(vector: unitVector(vector: velocity))
        let momentum = velocity
        var impluseX = GameConstants.Friction * unitNegatedVelocity.dx * CGFloat(seconds)
        var impluseY = GameConstants.Friction * unitNegatedVelocity.dy * CGFloat(seconds)
        if impluseX > 0 {
            impluseX = min(impluseX, -momentum.dx)
        } else {
            impluseX = max(impluseX, -momentum.dx)
        }
        if impluseY > 0 {
            impluseY = min(impluseY, -momentum.dy)
        } else {
            impluseY = max(impluseY, -momentum.dy)
        }
        position = CGPoint(x: position.x + CGFloat(seconds) * velocity.dx, y: position.y + CGFloat(seconds) * velocity.dy)
        velocity = CGVector(dx: velocity.dx + impluseX, dy: velocity.dy + impluseY)
    }
    
    var velocity:CGVector = CGVector(dx: 0, dy: 0)
    
    var p:CGPoint!
    //    var position: CGPoint!
    var position:CGPoint! {
        set {
            p = newValue
            node?.position = newValue
        }
        get {
            return p
        }
    }
    
    var isStable:Bool {
        return velocity.dx == 0 && velocity.dy == 0
    }
    
    var isNormalBall:Bool {
        return color == .Blue || color == .Red
    }
}
