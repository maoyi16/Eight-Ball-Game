//
//  RealBall.swift
//  Eight Ball Pool Game
//
//  Created by 毛易 on 2/20/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class RealBall: GKEntity, Ball {
    
    override func copy(with zone: NSZone? = nil) -> Any {
        return FakeBall(posX: node.position.x, posY: node.position.y, color: color, withNode: false)
    }
    
    override var description: String {
        return "{Color:\(color), Position: \(node!.position)}"
    }
    let node: SKShapeNode!
    let color: BallColor
    static let radius: CGFloat = GameConstants.BallRadius
    
    required init(posX: CGFloat, posY: CGFloat, color: BallColor) {
        self.color = color
        node = SKShapeNode(circleOfRadius: GameConstants.BallRadius)
        node.zPosition = 1
        defer {
            position = CGPoint(x: posX, y: posY)
        }
        node.strokeColor = .black
        node.physicsBody = SKPhysicsBody(circleOfRadius: GameConstants.BallRadius)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.mass = 1
        node.physicsBody?.restitution = 1
        node.physicsBody?.friction = 0
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.angularDamping = 0
        node.physicsBody?.allowsRotation = false
        node.fillColor = colorDict[color]!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard velocity.dx != 0 || velocity.dy != 0 else {
            return
        }
        let currentVelocity = node.physicsBody?.velocity
        let unitNegatedVelocity = negatedVector(vector: unitVector(vector: currentVelocity!))
        let momentum = currentVelocity
        var impluseX = GameConstants.Friction * unitNegatedVelocity.dx * CGFloat(seconds)
        var impluseY = GameConstants.Friction * unitNegatedVelocity.dy * CGFloat(seconds)
        if impluseX > 0 {
            impluseX = min(impluseX, -(momentum?.dx)!)
        } else {
            impluseX = max(impluseX, -(momentum?.dx)!)
        }
        if impluseY > 0 {
            impluseY = min(impluseY, -(momentum?.dy)!)
        } else {
            impluseY = max(impluseY, -(momentum?.dy)!)
        }
        let impluse = CGVector(dx: impluseX, dy: impluseY)
        node.physicsBody?.applyImpulse(impluse)
        
    }
    
    var velocity:CGVector {
        return (node.physicsBody?.velocity)!
    }
    
    var position:CGPoint! {
        set {
            node.position = newValue
        }
        get {
            return node.position
        }
    }
    
    var isStable:Bool {
        return node.physicsBody?.velocity.dx == 0 && node.physicsBody?.velocity.dy == 0
    }
    
    var isNormalBall:Bool {
        return color == .Blue || color == .Red
    }
}
